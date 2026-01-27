from std/httpcore import HttpHeaders, newHttpHeaders, `$`
from std/mimetypes import MimeDB, newMimeTypes, getMimeType
from std/asynchttpserver import AsyncHttpServer, newAsyncHttpServer

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
