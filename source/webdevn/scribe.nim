from std/paths import Path, getCurrentDir, parentDir, `$`
from std/strformat import fmt, `&`
from std/strutils import join
from std/uri import Uri, `$`
from std/syncio import File, fmAppend, close, write, flushFile
from std/times import now, format
from std/deques import Deque, initDeque, len, popFirst, addLast, items, clear

import type_defs


# Logger

type
  # Generic logger that respectst the cli flags
  aScribe* = ref object of RootObj
    willYap :bool
    willWrite :bool
    writeHandle :File
    willExpose :bool
    recentWrites :Deque[string]

  # Real logger used in app
  rScribe* = ref object of aScribe
  # Fake logger used in tests
  fScribe* = ref object of aScribe
    captured_msgs* :seq[string]

proc webdevnScribe* (appConfig :BluePrint) :rScribe =
  let scribo = rScribe(
    willYap: not appConfig.inSilence,
    willWrite: appConfig.logFile
  )

  if scribo.willWrite:
    if not appConfig.logForbidServe:
      scribo.willExpose = true
      scribo.recentWrites = initDeque[string](logLinesToKeep)

    if not open(scribo.writeHandle, &"{appConfig.basePath}/{logName}", fmAppend):
      scribo.willWrite = false
      echo "webdevn - Could not open log file"

  return scribo


proc mockScribe* (verbose :bool = false, toFile :bool = false, doRecent :bool = false) :fScribe =
  return fScribe(
    willYap: verbose,
    willWrite: toFile,
    willExpose: doRecent
  )


# Getting the text together

proc fmt_print_issues* (stuff :seq[string]) :string =
  var issueStr :string =
    if stuff.len == 0: "No issues!"
    else: stuff.join("\n    * ")

  return fmt"""
webdevn - issue(s) [{stuff.len}]:
  * {issueStr}
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


# Writing to console or file with respect to cli flag

proc write_log (scribo :aScribe, writeMsg :string) =
  if scribo.willWrite:
    let frmtdMsg = "[" & now().format("HH:mm:ss") & "]: " & writeMsg

    try:
      scribo.writeHandle.write(frmtdMsg & "\n")
      scribo.writeHandle.flushFile()
    except IOError as ioE:
      echo &"Issue writing to log file:\n    {ioE.name}: {ioE.msg}"

    if scribo.willExpose:
      if scribo.recentWrites.len >= logLinesToKeep:
        discard scribo.recentWrites.popFirst()

      scribo.recentWrites.addLast(frmtdMsg)


proc peek_log* (scribo :aScribe) :string =
  var peekBlob = ""

  for logLine in scribo.recentWrites:
    peekBlob.add(logLine & "\n")

  return peekBlob


proc scribe_inner (scribo :aScribe, scribeMsg :string) =
  echo scribeMsg
  scribo.write_log(scribeMsg)


proc log_issues* (scribo :aScribe, logStuff :seq[string]) =
  if scribo.willYap:
    if scribo of rScribe:
      scribo.scribe_inner(fmt_print_issues(logStuff))
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_issues(logStuff))


proc log_lookup* (scribo :aScribe, logReq :Uri, logMPath, logDRoot :Path) =
  if scribo.willYap:
    if scribo of rScribe:
      scribo.scribe_inner(fmt_print_lookup(logReq, logMPath, logDRoot))
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_lookup(logReq, logMPath, logDRoot))


proc log_it* (scribo :aScribe, logItBeing :string) =
  if scribo.willYap:
    if scribo of rScribe:
      scribo.scribe_inner(fmt_print_it(logItBeing))
    if scribo of fScribe:
      fScribe(scribo).captured_msgs.add(fmt_print_it(logItBeing))


# Important things that get shown regardless of the cli flag

proc spam_issues* (scribo :aScribe, spamStuff :seq[string]) =
  if scribo of rScribe:
    scribo.scribe_inner(fmt_print_issues(spamStuff))
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_issues(spamStuff))


proc spam_it* (scribo :aScribe, spamItBeing :string) =
  if scribo of rScribe:
    scribo.scribe_inner(fmt_print_it(spamItBeing))
  if scribo of fScribe:
    fScribe(scribo).captured_msgs.add(fmt_print_it(spamItBeing))


# Shutdown and clearout
proc o66* (scribo :aScribe) =
  scribo.spam_it("webdevn - shutting down...")

  if scribo.willWrite:
    if scribo.willExpose:
      scribo.recentWrites.clear()
    scribo.writeHandle.close()
