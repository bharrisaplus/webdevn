from std/paths import Path
from std/net import Port
from std/asynchttpserver import AsyncHttpServer, newAsyncHttpServer
from std/mimetypes import MimeDB, newMimeTypes


type webdevnConfig* = object
  basePath* :Path
  listenPort* :Port
  indexFile* :string
  indexFileExt* :string
  inSilence* :bool
  writeLog* :bool

proc defaultWebdevnConfig* :webdevnConfig =
  return webdevnConfig(
    basePath: paths.getCurrentDir(),
    listenPort: 0.Port,
    indexFile: "index.html",
    indexFileExt: "html",
    inSilence: true,
    writeLog: false
  )

proc devWebdevnConfig* :webdevnConfig =
  return webdevnConfig(
    basePath: paths.getCurrentDir(),
    listenPort: 0.Port,
    indexFile: "index.html",
    indexFileExt: "html",
    inSilence: false,
    writeLog: false
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

type
  scribeSkel* = ref object of RootObj
    doFile* :bool
    rotateFile* :bool
    maxRotate* :int
    logPath* :Path
    logName* :string

  rScribe* = ref object of scribeSkel
  fScribe* = ref object of scribeSkel

proc webdevnScribe* (someConfig :webdevnConfig) :rScribe =
  return rScribe(
    doFile: someConfig.writeLog,
    rotateFile: true,
    maxRotate: 3,
    logPath: paths.getCurrentDir(),
    logName: "webdevn.log.txt"
  )

type webdevnMilieu* = object
  runConf* :webdevnConfig
  runScribe* :scribeSkel
  baseHeaders* :headerBits = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-store, no-cache",
    "Clear-Site-Data": "\"cache\""
  }

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
