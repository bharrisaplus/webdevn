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
