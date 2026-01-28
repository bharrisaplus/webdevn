from std/strformat import fmt, `&`
from std/strutils import strip, toLowerAscii, startsWith, endsWith
from std/paths import Path, normalizePath, absolutePath, splitFile, getCurrentDir, `/`, `$`, `/`
from std/nativesockets import Port, `$`
from std/files import fileExists
from std/uri import Uri
from std/times import now, utc, format

import type_defs


proc print_config* (title :string = "webdevn", thingy :webdevnConfig) =
  var outputStr = title & " Config:\n"

  outputStr.add(&"  - basePath => '{thingy.basePath}'\n")
  outputStr.add(&"  - listenPort => {thingy.listenPort}\n")
  outputStr.add(&"  - indexFile => '{thingy.indexFile}'\n")
  outputStr.add(&"  - inSilence => {thingy.inSilence}\n")
  outputStr.add(&"  - writeLog => {thingy.writeLog}\n")

  echo outputStr


proc print_issues* (title :string = "webdevn", stuff :seq[string]) =
  var outputStr = title & " Issue(s) - [{stuff.len}]:\n"

  if stuff.len == 0:
    outputStr.add("  * No issues!\n")
  else:
    for issue in stuff:
      outputStr.add(&"  * {issue}\n")

  echo outputStr


proc print_milieu* (title :string = "webdevn", thingy :webdevnMilieu) =
  var outputStr = title & " Milieu/Runtime_Env:\n"

  outputStr.add("  runConf:\n")
  outputStr.add(&"    - basePath => '{thingy.runConf.basePath}'\n")
  outputStr.add(&"    - listenPort => {thingy.runConf.listenPort}\n")
  outputStr.add(&"    - indexFile => '{thingy.runConf.indexFile}'\n")
  outputStr.add(&"    - inSilence => {thingy.runConf.inSilence}\n")
  outputStr.add(&"    - writeLog => {thingy.runConf.writeLog}\n")

  outputStr.add("  baseHeaders:\n")

  for rheader in thingy.baseHeaders:
    outputStr.add("    {" & rheader.key & ": " & rheader.val & "}\n")

  echo outputStr


proc dir_contains_file* (maybeParent :Path, maybeChild :string) :bool =
  var maybeChildpath = Path(maybeChild)

  normalizePath(maybeChildpath)

  return fileExists(maybeParent / maybeChildPath)

proc lookup_from_url* (fsConfig :webdevnConfig, reqUrl :Uri) :lookupResult =
  discard

proc lazy_gobble* (morsel :string) =
  discard

# (m)ime(e)tag(c)ontent(t)ime_stamp
proc mect_stamp* (mimeType :string, fileLen: int) :headerBits =
  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or 
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let contentEncoding = if textLike: "; charset=utf-8" else: ""
  let currentTime = now().utc()

  return @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  }
