from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import fmt, `&`
from std/nativesockets import `$`
from std/uri import Uri, `$`

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

proc print_lookup* (title :string = "webdevn", req :Uri, mPath :Path, thingy :webdevnConfig) =
  var outputStr = "\n" & title & "Looking up request\n"

  outputStr.add(&"  - Request URL: {req}\n")
  outputStr.add(&"  - Request URL Path: {req.path}\n")
  outputStr.add(&"  - Request Absolute Path: {mPath}\n")
  outputStr.add(&"  - basePath: {thingy.basePath}\n")
  outputStr.add(&"  - basePath-Parent: {parentDir(thingy.basePath)}\n")
  outputStr.add(&"  - basePath-Parent-Parent: {parentDir(parentDir(thingy.basePath))}\n")

  echo outputStr

proc print_line* (gab :string) =
  echo "webdevn - " & gab


proc log_config* (s :scribeSkel, logTitle :string = "webdevn", logThingy :webdevnConfig) =
  if s of rScribe:
    if s.willYap:
      print_config(title = logTitle, thingy = logThingy)

    if s.doFile:
      discard
  else:
    discard


proc log_issues* (s :scribeSkel, logTitle :string = "webdevn", logStuff :seq[string]) =
  if s of rScribe:
    if s.willYap:
      print_issues(title = logTitle, stuff = logStuff)

    if s.doFile:
      discard
  else:
    discard


proc log_milieu* (s :scribeSkel, logTitle :string = "webdevn", logThingy :webdevnMilieu) =
  if s of rScribe:
    if s.willYap:
      print_milieu(title = logTitle, thingy = logThingy)

    if s.doFile:
      discard
  else:
    discard

proc log_lookup* (s :scribeSkel, logTitle :string = "webdevn", logReq :Uri, logMPath :Path, logthingy :webdevnConfig) =
  if s of rScribe:
    if s.willYap:
      print_lookup(title = logTitle, req = logReq, mPath = logMPath, thingy = logThingy)

    if s.doFile:
      discard
  else:
    discard


proc log_line* (s :scribeSkel, logGab :string) =
  if s of rScribe:
    if s.willYap:
      print_line(gab = logGab)

    if s.doFile:
      discard
  else:
    discard
