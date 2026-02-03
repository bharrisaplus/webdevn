from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import fmt, `&`
from std/strutils import join
from std/nativesockets import `$`
from std/uri import Uri, `$`

import type_defs


# Getting the text together

proc fmt_print_config* (thingy :webdevnConfig) :string =
  return fmt"""
  webdevn config:
    - basePath => {thingy.basePath}
    - inputPortNum => {thingy.inputPortNum}
    - indexFile => {thingy.indexFile}
    - inSilence => {thingy.inSilence}
    - writeLog => {thingy.writeLog}
  """


proc fmt_print_issues* (stuff :seq[string]) :string =
  var issueStr :string =
    if stuff.len == 0: "No issues!"
    else: stuff.join("\n    * ")

  return fmt"""
  webdevn issue(s) - [{stuff.len}]:
    * {issueStr}
  """


proc fmt_print_milieu* (thingy :webdevnMilieu) :string =
  return fmt"""
  webdevn milieu/runtime env:
    - docRoot => {thingy.virtualFS.docRoot}
    - docIndex => {thingy.virtualFS.docIndex}
    - docIndexExt => {thingy.virtualFS.docIndexExt}
    - listenPort => {thingy.listenPort}
  """


proc fmt_print_lookup* (req :Uri, mPath, dRoot :Path) :string =
  return fmt"""
  webdevn - request lookup:
    - Request URL: {req}
    - Request URL Path: {req.path}
    - Request Absolute Path: {mPath}
    - basePath: {dRoot}
    - basePath-Parent: {parentDir(dRoot)}
    - basePath-Parent-Parent: {parentDir(parentDir(dRoot))}
  """


proc fmt_print_it* (itBeing :string) :string =
  return fmt"webdevn - {itBeing}"


# General print to screen

proc print_it* (printItBeing :string) =
  echo fmt_print_it(printItBeing)


# Called with aScribe or children; writing to console or file with respect to cli flag 

proc log_config* (scribo :aScribe, logThingy :webdevnConfig) =
  if scribo.willYap:
    if scribo of rScribe:
      echo fmt_print_config(logThingy)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_config(logThingy))


proc log_issues* (scribo :aScribe, logStuff :seq[string]) =
  if scribo.willYap:
    if scribo of rScribe:
      echo fmt_print_issues(logStuff)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_issues(logStuff))


proc log_milieu* (scribo :aScribe, logThingy :webdevnMilieu) =
  if scribo.willYap:
    if scribo of rScribe:
      echo fmt_print_milieu(logThingy)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_milieu(logThingy))


proc log_lookup* (scribo :aScribe, logReq :Uri, logMPath, logDRoot :Path) =
  if scribo.willYap:
    if scribo of rScribe:
      echo fmt_print_lookup(logReq, logMPath, logDRoot)
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
    echo fmt_print_issues(spamStuff)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_issues(spamStuff))


proc spam_milieu* (scribo :aScribe, spamThingy :webdevnMilieu) =
  if scribo of rScribe:
    echo fmt_print_milieu(spamThingy)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_milieu(spamThingy))


proc spam_it* (scribo :aScribe, spamItBeing :string) =
  if scribo of rScribe:
    print_it(spamItBeing)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_it(spamItBeing))
