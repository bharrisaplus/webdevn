from std/strformat import fmt, `&`
from std/strutils import strip, toLowerAscii, startsWith, endsWith
from std/nativesockets import Port, `$`
from std/files import fileExists
from std/uri import Uri, `$`
from std/times import now, utc, format
from std/asyncfutures import Future, newFuture, complete
from std/asyncmacro import `async`, `await`
from std/asyncfile import AsyncFile, openAsync, readAll, close
from std/paths import Path,
  normalizePath, absolutePath, parentDir, splitFile, getCurrentDir, isRelativeTo,
  `/`, `$`

import type_defs


proc dir_contains_file* (maybeParent :Path, maybeChild :string) :bool =
  var maybeChildpath = Path(maybeChild)

  normalizePath(maybeChildpath)

  return fileExists(maybeParent / maybeChildPath)

proc lookup_from_url* (fsConfig :webdevnConfig, reqUrl :Uri) :lookupResult =
  let urlPath = reqUrl.path.strip(chars ={'/'})
  var
    maybeFilePath :Path #= Path(urlPath)
    maybeFileExt :string
    foundIt = false
    lookProblems :seq[string] = @[]

  if urlPath == "": # root directory
    maybeFilePath = fsConfig.basePath / Path(fsConfig.indexFile)
    maybeFileExt = fsConfig.indexFileExt
    foundIt = true
  else: # file or other directory (do lookup)
    maybeFilePath = absolutePath(path = Path(urlPath), root = fsConfig.basePath)

    let safeSearch = (
      maybeFilePath.isRelativeTo(fsConfig.basePath) or
      maybeFilePath.isRelativeTo(parentDir(fsConfig.basePath)) or
      maybeFilePath.isRelativeTo(parentDir(parentDir(fsConfig.basePath)))
    )

    if safeSearch:
      let maybeFileParts = splitFile(maybeFilePath)

      if maybeFileParts.ext == "": # other directory (look for indexFile)
        maybeFilePath = maybeFilePath / Path(fsConfig.indexFile)

        if dir_contains_file(maybeFilePath, fsConfig.indexFile):
          maybeFileExt = fsConfig.indexFileExt
          foundIt = true
      else: # file (do lookup)
        if fileExists(maybeFilePath):
          maybeFileExt = maybeFileParts.ext.toLowerAscii().strip(chars = {'.'})
          foundIt = true
  
  if not fsConfig.inSilence:
    echo "\nLooking up request"
    echo "Request URL: " & $reqUrl
    echo "Request URL Path: " & reqUrl.path
    echo "Request Absolute Path: " & maybeFilePath.string
    echo "basePath: " & fsConfig.basePath.string
    echo "basePath-Parent: " & parentDir(fsConfig.basePath).string
    echo "basePath-Parent-Parent: " & parentDir(parentDir(fsConfig.basePath)).string & "\n\n"

  if not foundIt:
    lookProblems.add(
      &"Issue with finding file from requested url:\n    Url:{reqUrl}\n    FilePath:{maybeFilePath}"
    )
    maybeFilePath = Path("")

  return (loc: maybeFilePath.string, ext: maybeFileExt, issues: lookProblems)


proc lazy_gobble* (gobbleConfig :webdevnConfig, morsel :string) :Future[gobbleResult] {.async.} =
  var
    nomnom :string
    file_blob :AsyncFile
    gobbleProblems :seq[string] = @[]

  try:
    file_blob = openAsync(morsel, fmRead)
    nomnom = await file_blob.readAll()
  except CatchableError as cE:
    # Issues
    gobbleProblems.add(&"Issue with reading file from path:\n    {cE.name}: {cE.msg}\n    Path: {morsel}")
  finally:
    file_blob.close()
  
  if not gobbleConfig.inSilence:
    echo "Reading file and returning contents"

  return (contents: nomnom, issues: gobbleProblems)


# (m)ime(e)tag(c)ontent(t)ime_stamp
proc mect_stamp* (mimeType :string, fileLen: int) :headerBits =
  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or 
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let contentEncoding = if textLike: "; charset=utf-8" else: ""
  let currentTime = now().utc()

  return @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  }
