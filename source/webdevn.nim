import std/[os]
from system import setControlCHook, quit
from asyncdispatch import waitFor

import webdevn/[type_defs, scribe, cli, localServer]


when isMainModule:
  let
    (cliConfig, cliIssues) = configFromCLi(commandLineParams())
    runScribe = webdevnScribe(cliConfig)
    currentMilieu = webdevnMilieu(runConf: cliConfig)

  if not cliConfig.oneOff:
    if cliIssues.len > 0:
      runScribe.spam_issues("Cli", cliIssues)
      quit("\nwebdevn - shutting down...\n", 0)

    let webdevnLoser = webdevnLocalServer(currentMilieu)

    setControlCHook(proc() {.noconv.} =
      runScribe.log_milieu("\nlocalserver", webdevnLoser.laMilieu)
      quit("\nwebdevn - shutting down...\n", 0)
    )

    runScribe.spam_milieu("localserver", webdevnLoser.laMilieu)
    
    waitFor webdevnLoser.wake_up(runScribe, 500)
