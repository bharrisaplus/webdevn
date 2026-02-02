from std/paths import Path, getCurrentDir
from std/net import Port
from std/mimetypes import MimeDB, newMimeTypes
from std/httpcore import HttpHeaders, HttpCode


# Startup config / POST

const flagOpts* :seq[string]= @["v", "verbose", "l", "log", "V", "version", "h", "help"]

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

# Misc

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

const baseHeaderBits* = @{
  "Server": "webdevn; nim/c",
  "Cache-Control": "no-store, no-cache",
  "Clear-Site-Data": "\"cache\""
}

type aioResponse* = tuple
  responseCode :HttpCode
  responseContent :string
  responseHeaders :HttpHeaders

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

# Runtime environment

type webdevnMilieu* = object
  runConf* :webdevnConfig
  mimeLookup* :MimeDB
  napTime* = 500 # How many ms to wait when server is busy

proc defaultWebdevnMilieu* (someConfig :webdevnConfig) :webdevnMilieu =
  return webdevnMilieu(
    runConf: someConfig,
    mimeLookup: newMimeTypes()
  )
