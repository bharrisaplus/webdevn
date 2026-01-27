from std/paths import Path
from std/net import Port

type webdevnConfig* = object
  basePath* :Path
  listenPort* :Port
  indexFile* :string
  inSilence* :bool
  writeLog* :bool
