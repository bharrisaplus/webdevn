from std/mimetypes import getMimeType
from asyncdispatch import sleepAsync
from std/asyncfutures import Future, newFuture
from std/asyncmacro import `async`, `await`
from std/strutils import startsWith, endsWith
from std/times import now, utc, format
from std/strformat import `&`
from std/httpcore import HttpHeaders, HttpCode, Http200, Http404, newHttpHeaders, `$`
from std/nativesockets import `$`
from std/sugar import `=>`
from std/asynchttpserver import Request,
  listen, getPort, shouldAcceptRequest, acceptRequest, respond

import type_defs, scribe, utils


proc stamp_headers* (loser :localServer, fileExt :string, fileLen: int) :HttpHeaders =
  let mimeType = loser.mimeLookup.getMimeType(fileExt)

  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let
    contentEncoding = if textLike: "; charset=utf-8" else: ""
    currentTime = now().utc()

  return newHttpHeaders(loser.serverMilieu.baseHeaders & @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  })

proc aio_respond_for* (loser :localServer, aioReq :Request) :owned(Future[void]) {.async.} =
  let
    errorContent = "<h2>404: Not Found</h2>"
    lookupInfo = lookup_from_url(
      webdevnLookupParts(loser.serverMilieu.runConf), loser.serverMilieu.runScribe, aioReq.url
    )

  var
    resContent :string
    resCode :HttpCode
    resHeaders :HttpHeaders
    isOk :bool

  if lookupInfo.issues.len == 0:
    isOk = true
  else:
    loser.serverMilieu.runScribe.log_issues("File lookup", lookupInfo.issues)

  if isOk:
    let gobbleInfo = await lazy_gobble(loser.serverMilieu.runScribe, lookupInfo.loc)

    if gobbleInfo.issues.len == 0:
      loser.serverMilieu.runScribe.log_it(&"(200) Found File\n\n")
      resContent = gobbleInfo.contents
      resCode = Http200
      resHeaders = loser.stamp_headers(lookupInfo.ext, resContent.len)

    else:
      loser.serverMilieu.runScribe.log_issues("File read", gobbleInfo.issues)
      isOk = false

  if not isOk:
    loser.serverMilieu.runScribe.log_it(&"(404) File Not Found\n\n")
    resContent = errorContent
    resCode = Http404
    resHeaders = loser.stamp_headers("html", resContent.len)

  loser.serverMilieu.runScribe.log_it(&"Stamped Headers: {resHeaders}\n")
  loser.serverMilieu.runScribe.spam_it(&"Responding to request: {aioReq.url}\n=============")

  await aioReq.respond(resCode, resContent, resHeaders)


proc wake_up* (loser: localServer, napTime: int) :Future[void] {.async.} =
  let listenAddress = if loser.serverMilieu.runConf.zeroHost: "0.0.0.0" else: "localhost"

  loser.innerDaemon.listen(loser.serverMilieu.runConf.listenPort)
  loser.serverMilieu.runScribe.spam_it("Starting up server")
  loser.serverMilieu.runScribe.spam_it(&"Listening on {listenAddress}:{loser.innerDaemon.getPort}")
  loser.serverMilieu.runScribe.spam_it("Press 'Ctrl+C' to exit\n\n")
  while true:
    if loser.innerDaemon.shouldAcceptRequest():
      await loser.innerDaemon.acceptRequest((r: Request) => loser.aio_respond_for(aioReq = r))
    else:
      await sleepAsync(napTime)
