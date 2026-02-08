from std/strformat import `&`
from std/strutils import strip, toLowerAscii
from std/files import fileExists
from std/uri import Uri
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


proc lookup_from_url* (reqUrl :Uri, lookupFS :webFS, urlScribe :aScribe) :lookupResult =
  let urlPath = reqUrl.path.strip(chars ={'/'})
  var
    maybeFilePath :Path
    maybeFileExt :string
    foundIt = false
    lookProblems :seq[string] = @[]

  if urlPath == "": # root directory
    maybeFilePath = lookupFS.docRoot / Path(lookupFS.docIndex)

    if fileExists(maybeFilePath):
      maybeFileExt = lookupFS.docIndexExt
      foundIt = true

  else: # file or other directory (do lookup)
    maybeFilePath = absolutePath(path = Path(urlPath), root = lookupFS.docRoot)

    let safeSearch = (
      maybeFilePath.isRelativeTo(lookupFS.docRoot) or
      maybeFilePath.isRelativeTo(parentDir(lookupFS.docRoot)) or
      maybeFilePath.isRelativeTo(parentDir(parentDir(lookupFS.docRoot)))
    )

    if safeSearch:
      let maybeFileParts = splitFile(maybeFilePath)

      if maybeFileParts.ext == "": # other directory (look for indexFile)
        maybeFilePath = maybeFilePath / Path(lookupFS.docIndex)

        if dir_contains_file(maybeFilePath, lookupFS.docIndex):
          maybeFileExt = lookupFS.docIndexExt
          foundIt = true

      else: # file (do lookup)
        if fileExists(maybeFilePath):
          maybeFileExt = maybeFileParts.ext.toLowerAscii().strip(chars = {'.'})
          foundIt = true

  urlScribe.log_lookup(
    logReq = reqUrl, logMPath = maybeFilePath, logDRoot = lookupFS.docRoot
  )

  if lookupFS.excludeLog and (urlPath == logName):
    foundIt = false

  if not foundIt:
    lookProblems.add(
      &"Issue with finding file from requested url:\n    Url:{reqUrl}\n    FilePath:{maybeFilePath}"
    )
    maybeFilePath = Path("")

  return (loc: maybeFilePath.string, ext: maybeFileExt, issues: lookProblems)


proc lazy_gobble* (morsel :string, gobbleScribe :aScribe) :Future[gobbleResult] {.async.} =
  var
    nomnom :string
    file_blob :AsyncFile
    gobbleProblems :seq[string] = @[]

  try:
    file_blob = openAsync(morsel, fmRead)
    nomnom = await file_blob.readAll()
  except ValueError as vE:
    gobbleProblems.add(&"Issue with reading file from path:\n    {vE.name}: {vE.msg}\n    Path: {morsel}")
  except OSError as osE:
    gobbleProblems.add(&"OS happenings while reading the file:\n    {osE.name}: {osE.msg}\n    Path: {morsel}")
  except Exception as bigE:
    gobbleProblems.add(&"Something occured while reading the file:\n    {bigE.name}: {bigE.msg}\n    Path: {morsel}")
  finally:
    if file_blob != nil:
      file_blob.close()

  gobbleScribe.log_it("Reading file and returning contents")

  return (contents: nomnom, issues: gobbleProblems)
