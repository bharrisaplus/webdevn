from std/paths import Path, getCurrentDir
from std/net import Port
from std/mimetypes import MimeDB, newMimeTypes
from std/httpcore import HttpHeaders, HttpCode


const
  # Cli options that don't need input
  flagOpts* :seq[string] = @["v", "verbose", "l", "log", "V", "version", "h", "help"]
  # Number of log files to keep
  maxRotate* :int = 3
  # How many ms to wait when server is busy
  napTime* = 500
  # Headers that aren't generated for every request
  baseHeaderBits* = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-store, no-cache",
    "Clear-Site-Data": "\"cache\""
  }


# Startup config / POST

type webdevnConfig* = object
  basePath* :Path
  inputPortNum* :int
  indexFile* :string
  indexFileExt* :string
  inSilence* :bool
  writeLog* :bool
  zeroHost* :bool
  oneOff* :bool = false

proc defaultWebdevnConfig* :webdevnConfig =
  return webdevnConfig(
    basePath: getCurrentDir(),
    inputPortNum: 0,
    indexFile: "index.html",
    indexFileExt: "html",
    inSilence: true,
    writeLog: false,
    zeroHost: false
  )


# Misc

type webFS* = ref object
  docRoot* :Path
  docIndex* :string
  docIndexExt* :string

proc webdevnFS* (someConfig :webdevnConfig) :webFS =
  return webFs(
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

type aioResponse* = tuple
  responseCode :HttpCode
  responseContent :string
  responseHeaders :HttpHeaders


# Logger

type
  aScribe* = ref object of RootObj
    willYap* :bool
    doFile* :bool
    logPath* :Path
    logName* :string

  rScribe* = ref object of aScribe
  fScribe* = ref object of aScribe

proc webdevnScribe* (someConfig :webdevnConfig) :rScribe =
  return rScribe(
    willYap: not someConfig.inSilence,
    doFile: someConfig.writeLog,
    logPath: getCurrentDir(),
    logName: "webdevn.log.txt"
  )


# Runtime environment

type webdevnMilieu* = object
  virtualFS* :webFS
  listenPort* :Port
  anyAddr* :bool
  mimeLookup* :MimeDB

proc defaultWebdevnMilieu* (someConfig :webdevnConfig) :webdevnMilieu =
  return webdevnMilieu(
    virtualFS: webdevnFS(someConfig),
    listenPort: Port(someConfig.inputPortNum),
    anyAddr: someConfig.zeroHost,
    mimeLookup: newMimeTypes()
  )
