from std/asynchttpserver import AsyncHttpServer, Request,
  newAsyncHttpServer, listen, getPort, shouldAcceptRequest, acceptRequest, respond
from std/mimetypes import MimeDB, newMimeTypes, getMimeType
from asyncdispatch import sleepAsync
from std/asyncfutures import Future, newFuture
from std/asyncmacro import `async`, `await`
from std/strutils import strip, startsWith
from std/httpcore import HttpHeaders, HttpCode, Http200, Http404, newHttpHeaders, `$`
from std/nativesockets import `$`
from std/sugar import `=>`

import type_defs, utils


type localServer* = object
  innerDaemon* :AsyncHttpServer
  mimeLookup* :MimeDB
  serverMilieu* :webdevnMilieu

proc newWebdevnLocalServer* (someMilieu :webdevnMilieu) :localServer =
  return localServer(
    innerDaemon: newAsyncHttpServer(),
    mimeLookup: newMimeTypes(),
    serverMilieu: someMilieu
  )


proc aio_respond_for* (s :localServer, aioReq :Request) :owned(Future[void]) {.async.} =
  let
    grettingContent = "<h2>Hello, World</h2>"
    errorContent = "<h2>404: Not Found</h2>"
    lookupInfo = lookup_from_url(s.serverMilieu.runConf, aioReq.url)

  var
    resContent :string
    resCode :HttpCode
    resHeaders :HttpHeaders
    isOk :bool

  if lookupInfo.issues.len == 0:
    isOk = true
  elif not s.serverMilieu.runConf.inSilence:
    print_issues("File lookup", lookupInfo.issues)

  if isOk:
    resContent = grettingContent
    resCode = Http200
    resHeaders = newHttpHeaders(s.serverMilieu.baseHeaders & mect_stamp(
      s.mimeLookup.getMimeType("html"), grettingContent.len
    ))
  else:
    resContent = errorContent
    resCode = Http404
    resHeaders = newHttpHeaders(s.serverMilieu.baseHeaders & mect_stamp(
      s.mimeLookup.getMimeType("html"), errorContent.len
    ))

  if not s.serverMilieu.runConf.inSilence:
    echo "\nResponding to request"
    echo "\nStamped Headers: " & $resHeaders & "\n\n"

  await aioReq.respond(resCode, resContent, resHeaders)


proc wake_up* (s: localServer, napTime: int) :Future[void] {.async.} =
  s.innerDaemon.listen(s.serverMilieu.runConf.listenPort)

  if not s.serverMilieu.runConf.inSilence:
    echo "webdevn - Starting up server"
    echo "webdevn - Using port " & $s.innerDaemon.getPort

  echo "\nPress 'Ctrl+C' to exit"
  while true:
    if s.innerDaemon.shouldAcceptRequest():
      await s.innerDaemon.acceptRequest((r: Request) => s.aio_respond_for(aioReq = r))
    else:
      await sleepAsync(napTime)
