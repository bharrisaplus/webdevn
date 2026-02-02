import std/[os]
from system import setControlCHook, quit
from asyncdispatch import waitFor

import webdevn/[type_defs, scribe, cli, localServer]


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
    
    waitFor localserver.wake_up(laMilieu, runScribe, 500)
