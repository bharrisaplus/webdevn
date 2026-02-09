from std/os import commandLineParams
from std/asyncfutures import Future, newFuture, complete
from std/asyncmacro import `async`, `await`
from asyncdispatch import waitFor, sleepAsync
from std/nativesockets import `$`
from std/strutils import join
from std/asynchttpserver import Request,
  newAsyncHttpServer, listen, getPort, shouldAcceptRequest, acceptRequest, respond

import webdevn/[type_defs, scribe, cli, localserver]


proc wake_up* (wakeupMilieu :webdevnMilieu, journal :aScribe) {.async.} =
  let
    listenAddress = if wakeupMilieu.anyAddr: "0.0.0.0" else: "localhost"
    innerDaemon = newAsyncHttpServer()

  innerDaemon.listen(wakeupMilieu.listenPort)
  journal.spam_it("Starting up server")
  journal.spam_it("Listening on " & listenAddress & ":" & $innerDaemon.getPort)
  journal.spam_it("Press 'Ctrl+C' to exit\n\n")
  while true:
    if innerDaemon.shouldAcceptRequest():
      await innerDaemon.acceptRequest() do (okRequest: Request) {.async.}:
        let (aioCode, aioContent, aioHeaders) = await localserver.aio_for(
          okRequest, wakeupMilieu.virtualFS, journal
        )

        await okRequest.respond(aioCode, aioContent, aioHeaders)
    else:
      await sleepAsync(napTime)


when isMainModule:
  let
    userArgs = commandLineParams()
    (cliConfig, cliIssues) = configFromCLi(userArgs)
    runScribe = webdevnScribe(cliConfig)
    laMilieu = defaultWebdevnMilieu(cliConfig)

  if not cliConfig.oneOff:
    if cliIssues.len > 0:
      runScribe.spam_issues(cliIssues)
      runScribe.spam_it("cli options ~> " & userArgs.join(" "))
      runScribe.o66()
      quit(0)

    setControlCHook(proc() {.noconv.} =
      echo "" # To not be interrupted by SIGINT message
      runScribe.log_milieu(laMilieu)
      runScribe.o66()
      quit(0)
    )

    runScribe.spam_milieu(laMilieu)
    
    waitFor wake_up(laMilieu, runScribe)
