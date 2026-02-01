from std/strformat import fmt, `&`
from std/strutils import strip, toLowerAscii, startsWith, endsWith
from std/nativesockets import Port, `$`
from std/files import fileExists
from std/uri import Uri
from std/times import now, utc, format
from std/asyncfutures import Future, newFuture, complete
from std/asyncmacro import `async`, `await`
from std/asyncfile import AsyncFile, openAsync, readAll, close
from std/paths import Path,
  normalizePath, absolutePath, parentDir, splitFile, getCurrentDir, isRelativeTo,
  `/`

import type_defs, scribe


proc dir_contains_file* (maybeParent :Path, maybeChild :string) :bool =
  var maybeChildpath = Path(maybeChild)

  normalizePath(maybeChildpath)

  return fileExists(maybeParent / maybeChildPath)

proc lookup_from_url* (fsMilieu :webdevnMilieu, reqUrl :Uri) :lookupResult =
  let urlPath = reqUrl.path.strip(chars ={'/'})
  var
    maybeFilePath :Path
    maybeFileExt :string
    foundIt = false
    lookProblems :seq[string] = @[]

  if urlPath == "": # root directory
    maybeFilePath = fsMilieu.runConf.basePath / Path(fsMilieu.runConf.indexFile)

    if fileExists(maybeFilePath):
      maybeFileExt = fsMilieu.runConf.indexFileExt
      foundIt = true

  else: # file or other directory (do lookup)
    maybeFilePath = absolutePath(path = Path(urlPath), root = fsMilieu.runConf.basePath)

    let safeSearch = (
      maybeFilePath.isRelativeTo(fsMilieu.runConf.basePath) or
      maybeFilePath.isRelativeTo(parentDir(fsMilieu.runConf.basePath)) or
      maybeFilePath.isRelativeTo(parentDir(parentDir(fsMilieu.runConf.basePath)))
    )

    if safeSearch:
      let maybeFileParts = splitFile(maybeFilePath)

      if maybeFileParts.ext == "": # other directory (look for indexFile)
        maybeFilePath = maybeFilePath / Path(fsMilieu.runConf.indexFile)

        if dir_contains_file(maybeFilePath, fsMilieu.runConf.indexFile):
          maybeFileExt = fsMilieu.runConf.indexFileExt
          foundIt = true

      else: # file (do lookup)
        if fileExists(maybeFilePath):
          maybeFileExt = maybeFileParts.ext.toLowerAscii().strip(chars = {'.'})
          foundIt = true

  fsMilieu.runScribe.log_lookup(
    logReq = reqUrl, logMPath = maybeFilePath, logThingy = fsMilieu.runConf
  )

  if not foundIt:
    lookProblems.add(
      &"Issue with finding file from requested url:\n    Url:{reqUrl}\n    FilePath:{maybeFilePath}"
    )
    maybeFilePath = Path("")

  return (loc: maybeFilePath.string, ext: maybeFileExt, issues: lookProblems)


proc lazy_gobble* (gobbleMilieu :webdevnMilieu, morsel :string) :Future[gobbleResult] {.async.} =
  var
    nomnom :string
    file_blob :AsyncFile
    gobbleProblems :seq[string] = @[]

  try:
    file_blob = openAsync(morsel, fmRead)
    nomnom = await file_blob.readAll()
  except ValueError as vE:
    gobbleProblems.add(&"Issue with reading file from path:\n    {vE.name}: {vE.msg}\n    Path: {morsel}")
  except Exception as bigE:
    gobbleProblems.add(&"Something occured while reading the file:\n    {bigE.name}: {bigE.msg}\n    Path: {morsel}")
  finally:
    file_blob.close()

  gobbleMilieu.runScribe.log_line("Reading file and returning contents")

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
