from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import fmt, `&`
from std/strutils import join
from std/nativesockets import `$`
from std/uri import Uri, `$`
from std/syncio import File, fmAppend, close, write, flushFile
from std/times import now, format

import type_defs


# Logger

type
  # Generic logger that respectst the cli flags
  aScribe* = ref object of RootObj
    willYap :bool
    willWrite :bool
    writeHandle :File

  # Real logger used in app
  rScribe* = ref object of aScribe
  # Fake logger used in tests
  fScribe* = ref object of aScribe
    captured_msgs* :seq[string]

proc webdevnScribe* (appConfig :webdevnConfig) :rScribe =
  let appScribe = rScribe(
    willYap: not appConfig.inSilence,
    willWrite: appConfig.logFile
  )

  if not open(appScribe.writeHandle, &"{appConfig.basePath}/{logName}", fmAppend):
    appScribe.willWrite = false
    echo "webdevn - Could not open log file"

  return appScribe


proc mockScribe* (verbose :bool = false, toFile :bool = false) :fScribe =
  return fScribe(
    willYap: verbose,
    willWrite: toFile
  )


# Getting the text together

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

proc write_log* (scribo :aScribe, writeMsg :string) =
  try:
    scribo.writeHandle.write("[" & now().format("HH:mm:ss") & "]: " & writeMsg & "\n")
    scribo.writeHandle.flushFile()
  except IOError as ioE:
    echo &"Issue writing to log file:\n    {ioE.name}: {ioE.msg}"


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
      echo fmt_print_it(logItBeing)
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_it(logItBeing))


# Important things that get shown regardless of the cli flag

proc spam_issues* (scribo :aScribe, spamStuff :seq[string]) =
  if scribo of rScribe:
    let spamMsg = fmt_print_issues(spamStuff)
    
    echo spamMsg

    if scribo.willWrite:
      scribo.write_log(spamMsg)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_issues(spamStuff))


proc spam_milieu* (scribo :aScribe, spamThingy :webdevnMilieu) =
  if scribo of rScribe:
    let spamMsg = fmt_print_milieu(spamThingy)

    echo spamMsg

    if scribo.willWrite:
      scribo.write_log(spamMsg)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_milieu(spamThingy))


proc spam_it* (scribo :aScribe, spamItBeing :string) =
  if scribo of rScribe:
    let spamMsg = fmt_print_it(spamItBeing)

    echo spamMsg

    if scribo.willWrite:
      scribo.write_log(spamMsg)
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_it(spamItBeing))


proc closeUp* (scribo :aScribe) =
  if scribo.willWrite:
    scribo.writeHandle.close()
