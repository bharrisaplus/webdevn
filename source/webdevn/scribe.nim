from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import `&`
from std/nativesockets import `$`
from std/uri import Uri, `$`

import type_defs

proc print_config* (title :string = "webdevn", thingy :webdevnConfig) =
  var outputStr = title & " Config:\n"

  outputStr.add(&"  - basePath => '{thingy.basePath}'\n")
  outputStr.add(&"  - inputPortNum => {thingy.inputPortNum}\n")
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

  outputStr.add(&"  - docRoot => '{thingy.virtualFS.docRoot}'\n")
  outputStr.add(&"  - docIndex => '{thingy.virtualFS.docIndex}'\n")
  outputStr.add(&"  - docIndexExt => '{thingy.virtualFS.docIndexExt}'\n")
  outputStr.add(&"  - listenPort => {thingy.listenPort}\n")

  echo outputStr

proc print_lookup* (title :string = "webdevn", req :Uri, mPath, dRoot :Path) =
  var outputStr = "\n" & title & "Looking up request\n"

  outputStr.add(&"  - Request URL: {req}\n")
  outputStr.add(&"  - Request URL Path: {req.path}\n")
  outputStr.add(&"  - Request Absolute Path: {mPath}\n")
  outputStr.add(&"  - basePath: {dRoot}\n")
  outputStr.add(&"  - basePath-Parent: {parentDir(dRoot)}\n")
  outputStr.add(&"  - basePath-Parent-Parent: {parentDir(parentDir(dRoot))}\n")

  echo outputStr


proc print_it* (itBeing :string) =
  echo "\nwebdevn - " & itBeing


proc log_config* (s :aScribe, logTitle :string = "webdevn", logThingy :webdevnConfig) =
  if s of rScribe:
    if s.willYap:
      print_config(title = logTitle, thingy = logThingy)

    if s.doFile:
      discard
  else:
    discard


proc log_issues* (s :aScribe, logTitle :string = "webdevn", logStuff :seq[string]) =
  if s of rScribe:
    if s.willYap:
      print_issues(title = logTitle, stuff = logStuff)

    if s.doFile:
      discard
  else:
    discard


proc log_milieu* (s :aScribe, logTitle :string = "webdevn", logThingy :webdevnMilieu) =
  if s of rScribe:
    if s.willYap:
      print_milieu(title = logTitle, thingy = logThingy)

    if s.doFile:
      discard
  else:
    discard

proc log_lookup* (s :aScribe, logTitle :string = "webdevn", logReq :Uri, logMPath, logDRoot :Path) =
  if s of rScribe:
    if s.willYap:
      print_lookup(title = logTitle, req = logReq, mPath = logMPath, dRoot = logDRoot)

    if s.doFile:
      discard
  else:
    discard


proc log_it* (s :aScribe, logItBeing :string) =
  if s of rScribe:
    if s.willYap:
      print_it(itBeing = logItBeing)

    if s.doFile:
      discard
  else:
    discard


proc spam_issues* (s :aScribe, spamTitle :string = "webdevn", spamStuff :seq[string]) =
  if s of rScribe:
    print_issues(title = spamTitle, stuff = spamStuff)
  else:
    discard


proc spam_milieu* (s :aScribe, spamTitle :string = "webdevn", spamThingy :webdevnMilieu) =
  if s of rScribe:
    print_milieu(title = spamTitle, thingy = spamThingy)
  else:
    discard


proc spam_it* (s :aScribe, spamItBeing :string) =
  if s of rScribe:
    print_it(itBeing = spamItBeing)
  else:
    discard
