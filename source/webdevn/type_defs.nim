import std/[paths, net]

type webdevnConfig* = object
  basePath*: Path
  listenPort*: Port
  indexFile*: Path
  inSilence*: bool
  writeLog*: bool
