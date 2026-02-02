from std/mimetypes import getMimeType
from std/asyncfutures import Future, newFuture, complete
from std/asyncmacro import `async`, `await`
from std/strutils import startsWith, endsWith
from std/times import now, utc, format
from std/strformat import `&`
from std/httpcore import HttpHeaders, HttpCode, Http200, Http404, newHttpHeaders, `$`
from std/asynchttpserver import Request

import type_defs, scribe, utils


proc stamp_headers* (fileExt :string, fileLen :int, stampMilieu :webdevnMilieu) :HttpHeaders =
  let mimeType = stampMilieu.mimeLookup.getMimeType(fileExt)

  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let
    contentEncoding = if textLike: "; charset=utf-8" else: ""
    currentTime = now().utc()

  return newHttpHeaders(baseHeaderBits & @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  })


proc aio_for* (aioReq :Request, aioMilieu :webdevnMilieu, aioScribe :aScribe) :Future[aioResponse] {.async.} =
  let
    errorContent = "<h2>404: Not Found</h2>"
    lookupInfo = lookup_from_url(aioReq.url, aioMilieu.virtualFS, aioScribe)

  var
    resContent :string
    resCode :HttpCode
    resHeaders :HttpHeaders
    isOk :bool

  if lookupInfo.issues.len == 0:
    isOk = true
  else:
    aioScribe.log_issues("File lookup", lookupInfo.issues)

  if isOk:
    let gobbleInfo = await lazy_gobble(lookupInfo.loc, aioScribe)

    if gobbleInfo.issues.len == 0:
      aioScribe.log_it(&"(200) Found File\n\n")
      resContent = gobbleInfo.contents
      resCode = Http200
      resHeaders = stamp_headers(lookupInfo.ext, resContent.len, aioMilieu)

    else:
      aioScribe.log_issues("File read", gobbleInfo.issues)
      isOk = false

  if not isOk:
    aioScribe.log_it(&"(404) File Not Found\n\n")
    resContent = errorContent
    resCode = Http404
    resHeaders = stamp_headers( "html", resContent.len, aioMilieu)

  aioScribe.log_it(&"Stamped Headers: {resHeaders}\n")
  aioScribe.spam_it(&"Responding to request: {aioReq.url}\n=============")

  return (responseCode: resCode, responseContent: resContent, responseHeaders: resHeaders)
