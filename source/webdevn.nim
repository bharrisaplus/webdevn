import std/[os]
from system import setControlCHook, quit
from asyncdispatch import waitFor

import webdevn/[type_defs, cli, utils, localServer]


when isMainModule:
  let
    (cliConfig, cliIssues) = configFromCLi(commandLineParams())
    currentMilieu = webdevnMilieu(runConf: cliConfig)

  if cliIssues.len > 0:
    print_Issues("Cli", cliIssues)
    quit("\nwebdevn - shutting down...\n", 0)

  let loser = webdevnLocalServer(currentMilieu)

  setControlCHook(proc() {.noconv.} =
    if not loser.serverMilieu.runConf.inSilence:
      print_milieu("\nlocalserver", loser.serverMilieu)

    quit("\nwebdevn - shutting down...\n", 0)
  )

  if not loser.serverMilieu.runConf.inSilence:
    print_milieu("localserver", loser.serverMilieu)
  
  waitFor loser.wake_up(500)
