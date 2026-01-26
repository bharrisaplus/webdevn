import std/[paths, net]

type webdevnConfig* = object
  basePath*: Path
  listenPort*: Port
  indexFile*: string
  inSilence*: bool
  writeLog*: bool
