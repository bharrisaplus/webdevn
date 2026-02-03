from std/paths import Path, getCurrentDir
from std/net import Port
from std/mimetypes import MimeDB, newMimeTypes
from std/httpcore import HttpHeaders, HttpCode


const
  # Cli options that don't need input
  flagOpts* :seq[string] = @["v", "verbose", "l", "log", "z", "zero", "V", "version", "h", "help"]
  # How many ms to wait when server is busy
  napTime* :int = 500
  # Single instance for getting the mime type on each request
  mimeLookup* :MimeDB = newMimeTypes()
  # Headers that are needed for every request but aren't generated
  baseHeaderBits* :seq[(string, string)] = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-store, no-cache",
    "Clear-Site-Data": "\"cache\""
  }


# Startup config / POST check
type webdevnConfig* = object
  basePath* :Path
  inputPortNum* :int
  indexFile* :string
  indexFileExt* :string
  inSilence* :bool
  zeroHost* :bool
  oneOff* :bool = false


# Misc

# Where requests are looked up from
type webFS* = ref object
  docRoot* :Path
  docIndex* :string
  docIndexExt* :string

# A found file to serve
type lookupResult* = tuple
  loc :string
  ext :string
  issues :seq[string]

# The innards of the requested file
type gobbleResult* = tuple
  contents :string
  issues :seq[string]

# all-in-one response vs a stream
type aioResponse* = tuple
  responseCode :HttpCode
  responseContent :string
  responseHeaders :HttpHeaders


# Logger

type
  # Generic logger that respectst the cli flags
  aScribe* = ref object of RootObj
    willYap* :bool

  # Real logger used in app
  rScribe* = ref object of aScribe
  # Fake logger used in tests
  fScribe* = ref object of aScribe
    captured_msgs* :seq[string]


# Runtime environment

type webdevnMilieu* = object
  virtualFS* :webFS
  listenPort* :Port
  anyAddr* :bool


# Helpers

proc defaultWebdevnConfig* :webdevnConfig =
  return webdevnConfig(
    basePath: getCurrentDir(),
    inputPortNum: 0,
    indexFile: "index.html",
    indexFileExt: "html",
    inSilence: true,
    zeroHost: false
  )


proc webdevnFS* (someConfig :webdevnConfig) :webFS =
  return webFs(
    docRoot: someConfig.basePath,
    docIndex: someConfig.indexFile,
    docIndexExt: someConfig.indexFileExt
  )


proc webdevnScribe* (someConfig :webdevnConfig) :rScribe =
  return rScribe(willYap: not someConfig.inSilence)


proc defaultWebdevnMilieu* (someConfig :webdevnConfig) :webdevnMilieu =
  return webdevnMilieu(
    virtualFS: webdevnFS(someConfig),
    listenPort: Port(someConfig.inputPortNum),
    anyAddr: someConfig.zeroHost
  )
