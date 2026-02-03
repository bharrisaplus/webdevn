from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import `&`
from std/nativesockets import `$`
from std/uri import Uri, `$`

import type_defs


# Getting the text together

proc fmt_print_config* (thingy :webdevnConfig) :string =
  var outputStr = "webdevn Config:\n"

  outputStr.add(&"  - basePath => '{thingy.basePath}'\n")
  outputStr.add(&"  - inputPortNum => {thingy.inputPortNum}\n")
  outputStr.add(&"  - indexFile => '{thingy.indexFile}'\n")
  outputStr.add(&"  - inSilence => {thingy.inSilence}\n")
  outputStr.add(&"  - writeLog => {thingy.writeLog}\n")

  return outputStr


proc fmt_print_issues* (stuff :seq[string]) :string =
  var outputStr = &"webdevn  Issue(s) - [{stuff.len}]:\n"

  if stuff.len == 0:
    outputStr.add("  * No issues!\n")
  else:
    for issue in stuff:
      outputStr.add(&"  * {issue}\n")

  return outputStr


proc fmt_print_milieu* (thingy :webdevnMilieu) :string =
  var outputStr = "webdevn Milieu/Runtime_Env:\n"

  outputStr.add(&"  - docRoot => '{thingy.virtualFS.docRoot}'\n")
  outputStr.add(&"  - docIndex => '{thingy.virtualFS.docIndex}'\n")
  outputStr.add(&"  - docIndexExt => '{thingy.virtualFS.docIndexExt}'\n")
  outputStr.add(&"  - listenPort => {thingy.listenPort}\n")

  return outputStr


proc fmt_print_lookup* (req :Uri, mPath, dRoot :Path) :string =
  var outputStr = "\n webdevn - Looking up request\n"

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

proc print_config* (printThingy :webdevnConfig) =
  echo fmt_print_config(printThingy)


proc print_issues* (printStuff :seq[string]) =
  echo fmt_print_issues(printStuff)


proc print_milieu* (printThingy :webdevnMilieu) =
  echo fmt_print_milieu(printThingy)


proc print_lookup* (printReq :Uri, printMPath, printDRoot :Path) =
  echo fmt_print_lookup(printReq, printMPath, printDRoot)


proc print_it* (printItBeing :string) =
  echo fmt_print_it(printItBeing)


# Called with aScribe or children

# Writing to console or file with respect to cli flag 

proc log_config* (scribo :aScribe, logThingy :webdevnConfig) =
  if scribo.willYap:
    if scribo of rScribe:
      print_config(logThingy)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_config(logThingy))


proc log_issues* (scribo :aScribe, logStuff :seq[string]) =
  if scribo.willYap:
    if scribo of rScribe:
      print_issues(logStuff)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_issues(logStuff))


proc log_milieu* (scribo :aScribe, logThingy :webdevnMilieu) =
  if scribo.willYap:
    if scribo of rScribe:
      print_milieu(logThingy)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_milieu(logThingy))


proc log_lookup* (scribo :aScribe, logReq :Uri, logMPath, logDRoot :Path) =
  if scribo.willYap:
    if scribo of rScribe:
      print_lookup(logReq, logMPath, logDRoot)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_lookup(logReq, logMPath, logDRoot))


proc log_it* (scribo :aScribe, logItBeing :string) =
  if scribo.willYap:
    if scribo of rScribe:
      print_it(logItBeing)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_it(logItBeing))


# Important things that get shown regardless of the cli flag

proc spam_issues* (scribo :aScribe, spamStuff :seq[string]) =
  if scribo of rScribe:
    print_issues(spamStuff)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_issues(spamStuff))


proc spam_milieu* (scribo :aScribe, spamThingy :webdevnMilieu) =
  if scribo of rScribe:
    print_milieu(spamThingy)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_milieu(spamThingy))


proc spam_it* (scribo :aScribe, spamItBeing :string) =
  if scribo of rScribe:
    print_it(spamItBeing)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_it(spamItBeing))
