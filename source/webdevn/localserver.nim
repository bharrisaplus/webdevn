from std/mimetypes import getMimeType
from asyncdispatch import sleepAsync
from std/asyncfutures import Future, newFuture, complete
from std/asyncmacro import `async`, `await`
from std/strutils import startsWith, endsWith
from std/times import now, utc, format
from std/strformat import `&`
from std/httpcore import HttpHeaders, HttpCode, Http200, Http404, newHttpHeaders, `$`
from std/nativesockets import `$`
from std/asynchttpserver import Request, newAsyncHttpServer,
  listen, getPort, shouldAcceptRequest, acceptRequest, respond

import type_defs, scribe, utils


let innerDaemon = newAsyncHttpServer()

proc stamp_headers* (stampMilieu :webdevnMilieu, fileExt :string, fileLen: int) :HttpHeaders =
  let mimeType = stampMilieu.mimeLookup.getMimeType(fileExt)

  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let
    contentEncoding = if textLike: "; charset=utf-8" else: ""
    currentTime = now().utc()

  return newHttpHeaders(stampMilieu.baseHeaders & @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  })


proc aio_for* (aioMilieu :webdevnMilieu, aioScribe :aScribe, aioReq :Request) :Future[aioResponse] {.async.} =
  let
    errorContent = "<h2>404: Not Found</h2>"
    lookupInfo = lookup_from_url(
      webdevnLookupParts(aioMilieu.runConf), aioScribe, aioReq.url
    )

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
    let gobbleInfo = await lazy_gobble(aioScribe, lookupInfo.loc)

    if gobbleInfo.issues.len == 0:
      aioScribe.log_it(&"(200) Found File\n\n")
      resContent = gobbleInfo.contents
      resCode = Http200
      resHeaders = stamp_headers(aioMilieu, lookupInfo.ext, resContent.len)

    else:
      aioScribe.log_issues("File read", gobbleInfo.issues)
      isOk = false

  if not isOk:
    aioScribe.log_it(&"(404) File Not Found\n\n")
    resContent = errorContent
    resCode = Http404
    resHeaders = stamp_headers(aioMilieu, "html", resContent.len)

  aioScribe.log_it(&"Stamped Headers: {resHeaders}\n")
  aioScribe.spam_it(&"Responding to request: {aioReq.url}\n=============")

  return (responseCode: resCode, responseContent: resContent, responseHeaders: resHeaders)


proc wake_up* (wakeupMilieu: webdevnMilieu, wakeupScribe: aScribe, napTime: int) :Future[void] {.async.} =
  let listenAddress = if wakeupMilieu.runConf.zeroHost: "0.0.0.0" else: "localhost"

  innerDaemon.listen(wakeupMilieu.runConf.listenPort)
  wakeupScribe.spam_it("Starting up server")
  wakeupScribe.spam_it(&"Listening on {listenAddress}:{innerDaemon.getPort}")
  wakeupScribe.spam_it("Press 'Ctrl+C' to exit\n\n")
  while true:
    if innerDaemon.shouldAcceptRequest():
      await innerDaemon.acceptRequest() do (aRequest: Request) {.async.}:
        let (aioCode, aioContent, aioHeaders) = await aio_for(wakeupMilieu, wakeupScribe, aRequest)

        await aRequest.respond(aioCode, aioContent, aioHeaders)
    else:
      await sleepAsync(napTime)
