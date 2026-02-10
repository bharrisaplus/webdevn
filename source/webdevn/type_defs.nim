from std/paths import Path, getCurrentDir
from std/mimetypes import MimeDB, newMimeTypes
from std/httpcore import HttpHeaders, HttpCode


const
  # Cli options that don't need input
  flagOpts* :seq[string] = @[
    "v", "verbose", "l", "logfile", "f", "forbidlogserve", "z", "zero", "V", "version", "h", "help"
  ]
  # How many ms to wait when server is busy
  napTime* :int = 500
  # Single instance for getting the mime type on each request
  mimeLookup* :MimeDB = newMimeTypes()
  notFoundContent* :string = "<h2 style=\"justify-self:center\">404: Not Found</h2>"
  logName* :string = "webdevn.log"
  # Headers that are needed for every request but aren't generated
  baseHeaderBits* :seq[(string, string)] = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-store, no-cache",
    "Clear-Site-Data": "\"cache\"",
    "X-Content-Type-Options": "nosniff"
  }
  # Headers to cache default favicon if one is not present
  faviconHeaderBits* :seq[(string, string)] = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "public, max-age=300",
    "X-Content-Type-Options": "nosniff",
    "Content-Type": "image/x-icon"
  }


# Startup config / POST check
type BluePrint* = object
  basePath* :Path
  inputPortNum* :int
  indexFile* :string
  indexFileExt* :string
  inSilence* :bool = true
  logFile* :bool = false
  logForbidServe* :bool = false
  zeroHost* :bool = false
  oneOff* :bool = false


# Misc

type WebFS* = ref object
  docRoot* :Path
  docIndex* :string
  docIndexExt* :string
  excludeLog* :bool

type LookupResult* = tuple
  loc :string
  ext :string
  issues :seq[string]

type GobbleResult* = tuple
  contents :string
  issues :seq[string]

type AIOResponse* = tuple
  responseCode :HttpCode
  responseContent :string
  responseHeaders :HttpHeaders


# Helpers

proc defaultBluePrint* :BluePrint =
  return BluePrint(
    basePath: getCurrentDir(),
    inputPortNum: 0,
    indexFile: "index.html",
    indexFileExt: "html"
  )


proc webdevnFS* (someConfig :BluePrint) :WebFS =
  return WebFS(
    docRoot: someConfig.basePath,
    docIndex: someConfig.indexFile,
    docIndexExt: someConfig.indexFileExt,
    excludeLog: someConfig.logForbidServe
  )
