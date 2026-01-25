import std/[paths]

type webdevnConfig* = object
  basePath*: Path
  listenPort*: int
  indexFile*: Path
  inSilence*: bool
  writeLog*: bool
