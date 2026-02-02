from std/os import commandLineParams
from system import setControlCHook, quit
from std/asyncmacro import `async`, `await`
from asyncdispatch import waitFor, sleepAsync
from std/asyncfutures import Future, newFuture, complete
from std/nativesockets import `$`
from std/asynchttpserver import Request,
  newAsyncHttpServer, listen, getPort, shouldAcceptRequest, acceptRequest, respond

import webdevn/[type_defs, scribe, cli, localServer]


proc wake_up* (wakeupMilieu: webdevnMilieu, wakeupScribe: aScribe) :Future[void] {.async.} =
  let
    listenAddress = if wakeupMilieu.runConf.zeroHost: "0.0.0.0" else: "localhost"
    innerDaemon = newAsyncHttpServer()

  innerDaemon.listen(wakeupMilieu.runConf.listenPort)
  wakeupScribe.spam_it("Starting up server")
  wakeupScribe.spam_it("Listening on " & listenAddress & ":{localserver.innerDaemon.getPort}")
  wakeupScribe.spam_it("Press 'Ctrl+C' to exit\n\n")
  while true:
    if innerDaemon.shouldAcceptRequest():
      await innerDaemon.acceptRequest() do (aRequest: Request) {.async.}:
        let (aioCode, aioContent, aioHeaders) = await localserver.aio_for(wakeupMilieu, wakeupScribe, aRequest)

        await aRequest.respond(aioCode, aioContent, aioHeaders)
    else:
      await sleepAsync(wakeupMilieu.napTime)


when isMainModule:
  let
    (cliConfig, cliIssues) = configFromCLi(commandLineParams())
    runScribe = webdevnScribe(cliConfig)
    laMilieu = defaultWebdevnMilieu(cliConfig)

  if not cliConfig.oneOff:
    if cliIssues.len > 0:
      runScribe.spam_issues("Cli", cliIssues)
      quit("\nwebdevn - shutting down...\n", 0)

    setControlCHook(proc() {.noconv.} =
      runScribe.log_milieu("\nlocalserver", laMilieu)
      quit("\nwebdevn - shutting down...\n", 0)
    )

    runScribe.spam_milieu("localserver", laMilieu)
    
    waitFor wake_up(laMilieu, runScribe)
