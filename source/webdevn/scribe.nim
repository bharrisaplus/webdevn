from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import `&`
from std/nativesockets import `$`
from std/uri import Uri, `$`

import type_defs


# Getting the text together

proc fmt_print_config* (title :string = "webdevn", thingy :webdevnConfig) :string =
  var outputStr = title & " Config:\n"

  outputStr.add(&"  - basePath => '{thingy.basePath}'\n")
  outputStr.add(&"  - inputPortNum => {thingy.inputPortNum}\n")
  outputStr.add(&"  - indexFile => '{thingy.indexFile}'\n")
  outputStr.add(&"  - inSilence => {thingy.inSilence}\n")
  outputStr.add(&"  - writeLog => {thingy.writeLog}\n")

  return outputStr


proc fmt_print_issues* (title :string = "webdevn", stuff :seq[string]) :string =
  var outputStr = &"{title}  Issue(s) - [{stuff.len}]:\n"

  if stuff.len == 0:
    outputStr.add("  * No issues!\n")
  else:
    for issue in stuff:
      outputStr.add(&"  * {issue}\n")

  return outputStr


proc fmt_print_milieu* (title :string = "webdevn", thingy :webdevnMilieu) :string =
  var outputStr = title & " Milieu/Runtime_Env:\n"

  outputStr.add(&"  - docRoot => '{thingy.virtualFS.docRoot}'\n")
  outputStr.add(&"  - docIndex => '{thingy.virtualFS.docIndex}'\n")
  outputStr.add(&"  - docIndexExt => '{thingy.virtualFS.docIndexExt}'\n")
  outputStr.add(&"  - listenPort => {thingy.listenPort}\n")

  return outputStr


proc fmt_print_lookup* (title :string = "webdevn", req :Uri, mPath, dRoot :Path) :string =
  var outputStr = "\n" & title & "Looking up request\n"

  outputStr.add(&"  - Request URL: {req}\n")
  outputStr.add(&"  - Request URL Path: {req.path}\n")
  outputStr.add(&"  - Request Absolute Path: {mPath}\n")
  outputStr.add(&"  - basePath: {dRoot}\n")
  outputStr.add(&"  - basePath-Parent: {parentDir(dRoot)}\n")
  outputStr.add(&"  - basePath-Parent-Parent: {parentDir(parentDir(dRoot))}\n")

  return outputStr


proc fmt_print_it* (itBeing :string) :string =
  return "\nwebdevn - " & itBeing


# General print to screen

proc print_config* (printTitle :string, printThingy :webdevnConfig) =
  echo fmt_print_config(printTitle, printThingy)


proc print_issues* (printTitle :string, printStuff :seq[string]) =
  echo fmt_print_issues(printTitle, printStuff)


proc print_milieu* (printTitle :string, printThingy :webdevnMilieu) =
  echo fmt_print_milieu(printTitle, printThingy)


proc print_lookup* (printTitle :string, printReq :Uri, printMPath, printDRoot :Path) =
  echo fmt_print_lookup(printTitle, printReq, printMPath, printDRoot)


proc print_it* (printItBeing :string) =
  echo fmt_print_it(printItBeing)


# Called with aScribe or children

# Writing to console or file with respect to cli flag 

proc log_config* (scribo :aScribe, logTitle :string = "webdevn", logThingy :webdevnConfig) =
  if scribo of rScribe:
    if scribo.willYap:
      print_config(logTitle, logThingy)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_config(logTitle, logThingy))
  else:
    discard


proc log_issues* (scribo :aScribe, logTitle :string = "webdevn", logStuff :seq[string]) =
  if scribo of rScribe:
    if scribo.willYap:
      print_issues(logTitle, logStuff)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_issues(logTitle, logStuff))
  else:
    discard


proc log_milieu* (scribo :aScribe, logTitle :string = "webdevn", logThingy :webdevnMilieu) =
  if scribo of rScribe:
    if scribo.willYap:
      print_milieu(logTitle, logThingy)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_milieu(logTitle, logThingy))
  else:
    discard

proc log_lookup* (scribo :aScribe, logTitle :string = "webdevn", logReq :Uri, logMPath, logDRoot :Path) =
  if scribo of rScribe:
    if scribo.willYap:
      print_lookup(logTitle, logReq, logMPath, logDRoot)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_lookup(logTitle, logReq, logMPath, logDRoot))
  else:
    discard


proc log_it* (scribo :aScribe, logItBeing :string) =
  if scribo of rScribe:
    if scribo.willYap:
      print_it(logItBeing)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_it(logItBeing))
  else:
    discard


# Important things that get shown regardless of the cli flag

proc spam_issues* (scribo :aScribe, spamTitle :string = "webdevn", spamStuff :seq[string]) =
  if scribo of rScribe:
    print_issues(spamTitle, spamStuff)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_issues(spamTitle, spamStuff))
  else:
    discard


proc spam_milieu* (scribo :aScribe, spamTitle :string = "webdevn", spamThingy :webdevnMilieu) =
  if scribo of rScribe:
    print_milieu(spamTitle, spamThingy)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_milieu(spamTitle, spamThingy))
  else:
    discard


proc spam_it* (scribo :aScribe, spamItBeing :string) =
  if scribo of rScribe:
    print_it(spamItBeing)

    if scribo.doFile:
      discard
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_it(spamItBeing))
  else:
    discard
