from std/httpcore import HttpHeaders, newHttpHeaders, `$`
from std/mimetypes import MimeDB, newMimeTypes, getMimeType
from std/asynchttpserver import AsyncHttpServer, newAsyncHttpServer
from system import setControlCHook, quit

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
  let loser = newWebdevnLocalServer(webdevnMilieu(runConf: devWebdevnConfig()))
  let grettingContent = "Hello, World"

  if not loser.serverMilieu.runConf.inSilence:
    print_milieu("localserver", loser.serverMilieu)

  var otfHeaders = newHttpHeaders(loser.serverMilieu.baseHeaders & mect_stamp(
    loser.mimeLookup.getMimeType(loser.serverMilieu.runConf.indexFileExt),
    getMD5(grettingContent),
    grettingContent.len
  ))

  echo "Stamped Headers: " & $otfHeaders

  setControlCHook(proc() {.noconv.} =
    if not loser.serverMilieu.runConf.inSilence:
      print_milieu("\nlocalserver", loser.serverMilieu)

    quit("\nwebdevn - shutting down...\n", 0)
  )

  echo "\nPress 'Ctrl+C' to exit"
  while true:
    discard
