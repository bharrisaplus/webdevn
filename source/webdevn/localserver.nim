from std/asynchttpserver import AsyncHttpServer, Request, newAsyncHttpServer, listen, getPort, shouldAcceptRequest, acceptRequest, respond
from std/mimetypes import MimeDB, newMimeTypes, getMimeType
from asyncdispatch import sleepAsync
from std/asyncfutures import Future, newFuture
from std/asyncmacro import `async`, `await`
from std/strutils import strip, startsWith
from std/paths import Path, absolutePath, parentDir, isRelativeTo
from std/httpcore import HttpHeaders, HttpCode, Http200, Http404, newHttpHeaders, `$`
from std/uri import Uri, `$`
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
  var rReqPath = Path(aioReq.url.path.strip(chars ={'/'}))
  var absReqPath = absolutePath(path = rReqPath, root = s.serverMilieu.runConf.basePath)

  let grettingContent = "<h2>Hello, World</h2>"
  let errorContent = "<h2>404: Not Found</h2>"
  var resContent :string
  var resCode :HttpCode
  var resHeaders :HttpHeaders

  let isOk = (
    absReqPath.isRelativeTo(s.serverMilieu.runConf.basePath) or
    absReqPath.isRelativeTo(parentDir(s.serverMilieu.runConf.basePath)) or
    absReqPath.isRelativeTo(parentDir(parentDir(s.serverMilieu.runConf.basePath)))
  )

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
    echo "Request URL: " & $aioReq.url
    echo "Request Path: " & aioReq.url.path
    echo "Request Path Path: " & rReqPath.string
    echo "Request Path Absolute Path: " & absReqPath.string
    echo "Base: " & s.serverMilieu.runConf.basePath.string
    echo "Base-Parent: " & parentDir(s.serverMilieu.runConf.basePath).string
    echo "Base-Parent-Parent: " & parentDir(parentDir(s.serverMilieu.runConf.basePath)).string
    echo "Request Path is relative to base: " & $absReqPath.isRelativeTo(s.serverMilieu.runConf.basePath)
    echo "Request Path is relative to base-Parent: " & $absReqPath.isRelativeTo(parentDir(s.serverMilieu.runConf.basePath))
    echo "Request Path is relative to base-Parent-Parent: " & $absReqPath.isRelativeTo(parentDir(parentDir(s.serverMilieu.runConf.basePath)))
    echo "\n\nStamped Headers: " & $resHeaders & "\n\n"

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
