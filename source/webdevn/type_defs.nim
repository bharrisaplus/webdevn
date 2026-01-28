from std/paths import Path
from std/net import Port

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
  loc, ext, :string
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

type webdevnMilieu* = object
  runConf* :webdevnConfig
  baseHeaders* :headerBits = @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-store, no-cache",
    "Clear-Site-Data": "\"cache\""
  }

type scribeSkel* = object
  doFile* :bool
  rotateFile* :bool
  maxRotate* :int
  logPath* :Path
  logName* :string

type
  rScribe* = ref scribeSkel
  fScribe* = ref scribeSkel

proc defaultScribe* :rScribe =
  return rScribe(
    doFile: false,
    rotateFile: false,
    maxRotate: 0,
    logPath: Path(""),
    logName: ""
  )

proc devScribe* :rScribe =
  return rScribe(
    doFile: true,
    rotateFile: true,
    maxRotate: 3,
    logPath: paths.getCurrentDir(),
    logName: "webdevn_dev.log.txt"
  )
