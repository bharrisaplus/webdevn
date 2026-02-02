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


proc stamp_headers* (s :localServer, fileExt :string, fileLen: int) :HttpHeaders =
  let mimeType = s.mimeLookup.getMimeType(fileExt)

  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let
    contentEncoding = if textLike: "; charset=utf-8" else: ""
    currentTime = now().utc()

  return newHttpHeaders(s.serverMilieu.baseHeaders & @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  })

proc aio_respond_for* (s :localServer, aioReq :Request) :owned(Future[void]) {.async.} =
  let
    errorContent = "<h2>404: Not Found</h2>"
    lookupInfo = lookup_from_url(
      webdevnLookupParts(s.serverMilieu.runConf), s.serverMilieu.runScribe, aioReq.url
    )

  var
    resContent :string
    resCode :HttpCode
    resHeaders :HttpHeaders
    isOk :bool

  if lookupInfo.issues.len == 0:
    isOk = true
  else:
    s.serverMilieu.runScribe.log_issues("File lookup", lookupInfo.issues)

  if isOk:
    let gobbleInfo = await lazy_gobble(s.serverMilieu.runScribe, lookupInfo.loc)

    if gobbleInfo.issues.len == 0:
      s.serverMilieu.runScribe.log_it(&"(200) Found File\n\n")
      resContent = gobbleInfo.contents
      resCode = Http200
      resHeaders = s.stamp_headers(lookupInfo.ext, resContent.len)

    else:
      s.serverMilieu.runScribe.log_issues("File read", gobbleInfo.issues)
      isOk = false

  if not isOk:
    s.serverMilieu.runScribe.log_it(&"(404) File Not Found\n\n")
    resContent = errorContent
    resCode = Http404
    resHeaders = s.stamp_headers("html", resContent.len)

  s.serverMilieu.runScribe.log_it(&"Stamped Headers: {resHeaders}\n")
  s.serverMilieu.runScribe.spam_it(&"Responding to request: {aioReq.url}\n=============")

  await aioReq.respond(resCode, resContent, resHeaders)


proc wake_up* (s: localServer, napTime: int) :Future[void] {.async.} =
  let listenAddress = if s.serverMilieu.runConf.zeroHost: "0.0.0.0" else: "localhost"

  s.innerDaemon.listen(s.serverMilieu.runConf.listenPort)
  s.serverMilieu.runScribe.spam_it("Starting up server")
  s.serverMilieu.runScribe.spam_it(&"Listening on {listenAddress}:{s.innerDaemon.getPort}")
  s.serverMilieu.runScribe.spam_it("Press 'Ctrl+C' to exit\n\n")
  while true:
    if s.innerDaemon.shouldAcceptRequest():
      await s.innerDaemon.acceptRequest((r: Request) => s.aio_respond_for(aioReq = r))
    else:
      await sleepAsync(napTime)
