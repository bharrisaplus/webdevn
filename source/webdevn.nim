import std/[os]
from system import setControlCHook, quit
from asyncdispatch import waitFor

import webdevn/[type_defs, scribe, cli, localServer]


when isMainModule:
  let
    (cliConfig, cliIssues) = configFromCLi(commandLineParams())
    currentMilieu = webdevnMilieu(runConf: cliConfig, runScribe: webdevnScribe(cliConfig))

  if not cliConfig.oneOff:
    if cliIssues.len > 0:
      currentMilieu.runScribe.spam_issues("Cli", cliIssues)
      quit("\nwebdevn - shutting down...\n", 0)

    let webdevnLoser = webdevnLocalServer(currentMilieu)

    setControlCHook(proc() {.noconv.} =
      currentMilieu.runScribe.log_milieu("\nlocalserver", webdevnLoser.serverMilieu)
      quit("\nwebdevn - shutting down...\n", 0)
    )

    currentMilieu.runScribe.spam_milieu("localserver", webdevnLoser.serverMilieu)
    
    waitFor webdevnLoser.wake_up(500)
