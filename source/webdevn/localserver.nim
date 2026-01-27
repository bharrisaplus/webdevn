from std/httpcore import newHttpHeaders, `$`
from std/mimetypes import MimeDB, newMimeTypes, getMimeType
from std/asynchttpserver import AsyncHttpServer, newAsyncHttpServer
from system import debugEcho

from checksums/md5 import getMD5

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


when isMainModule:
  let loser = newWebdevnLocalServer(webdevnMilieu(runConf: defaultWebdevnConfig()))
  let grettingContent = "Hello, World"

  var otfHeaders = newHttpHeaders(loser.serverMilieu.baseHeaders & mect_stamp(
    loser.mimeLookup.getMimeType(loser.serverMilieu.runConf.indexFileExt),
    getMD5(grettingContent),
    grettingContent.len
  ))

  print_milieu("localserver", loser.serverMilieu)
  debugEcho(otfHeaders)
