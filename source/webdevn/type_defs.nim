from std/paths import Path, getCurrentDir
from std/net import Port
from std/asynchttpserver import AsyncHttpServer, newAsyncHttpServer
from std/mimetypes import MimeDB, newMimeTypes


# Startup config / POST

type webdevnConfig* = object
  basePath* :Path
  listenPort* :Port
  indexFile* :string
  indexFileExt* :string
  inSilence* :bool
  writeLog* :bool
  zeroHost* :bool
  oneOff* = false

proc defaultWebdevnConfig* :webdevnConfig =
  return webdevnConfig(
    basePath: getCurrentDir(),
    listenPort: Port(0),
    indexFile: "index.html",
    indexFileExt: "html",
    inSilence: true,
    writeLog: false,
    zeroHost: false
  )

proc devWebdevnConfig* :webdevnConfig =
  return webdevnConfig(
    basePath: getCurrentDir(),
    listenPort: 0.Port,
    indexFile: "index.html",
    indexFileExt: "html",
    inSilence: false,
    writeLog: false,
    zeroHost: false
  )

# Misc params and/or return types

type lookupParts* = tuple
  docRoot :Path # webdevnConfig.basePath
  docIndex :string # webdevnConfig.indexFile
  docIndexExt :string # webdevnConfig.indexFileExt

proc webdevnLookupParts* (someConfig :webdevnConfig) :lookupParts =
  return (
    docRoot: someConfig.basePath,
    docIndex: someConfig.indexFile,
    docIndexExt: someConfig.indexFileExt
  )

type lookupResult* = tuple
  loc :string
  ext :string
  issues :seq[string]

type gobbleResult* = tuple
  contents :string
  issues :seq[string]

type headerBits* = seq[
  tuple[
    key :string,
    val :string
  ]
]

# Logger

type
  aScribe* = ref object of RootObj
    willYap* :bool
    doFile* :bool
    rotateFile* :bool
    maxRotate* :int
    logPath* :Path
    logName* :string

  rScribe* = ref object of aScribe
  fScribe* = ref object of aScribe

proc webdevnScribe* (someConfig :webdevnConfig) :rScribe =
  return rScribe(
    willYap: not someConfig.inSilence,
    doFile: someConfig.writeLog,
    rotateFile: true,
    maxRotate: 3,
    logPath: getCurrentDir(),
    logName: "webdevn.log.txt"
  )

# Runtime environment / Server config

type webdevnMilieu* = object
  runConf* :webdevnConfig
  runScribe* :aScribe
  baseHeaders* :headerBits = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-store, no-cache",
    "Clear-Site-Data": "\"cache\""
  }

# Server

type localServer* = object
  innerDaemon* :AsyncHttpServer
  mimeLookup* :MimeDB
  serverMilieu* :webdevnMilieu

proc webdevnLocalServer* (someMilieu :webdevnMilieu) :localServer =
  return localServer(
    innerDaemon: newAsyncHttpServer(),
    mimeLookup: newMimeTypes(),
    serverMilieu: someMilieu
  )
