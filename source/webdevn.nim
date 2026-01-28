import std/[os]
from system import setControlCHook, quit
from asyncdispatch import waitFor

import webdevn/[type_defs, cli, utils, localServer]


when isMainModule:
  var webdevnIssues :seq[string]
  let (cliConfig, cliIssues) = configFromCLi(commandLineParams())

  if cliIssues.len > 0:
    webdevnIssues.add(cliIssues)
    print_Issues("Cli", webdevnIssues)
    quit("\nwebdevn - shutting down...\n", 0)

  let loser = newWebdevnLocalServer(webdevnMilieu(runConf: cliConfig))

  setControlCHook(proc() {.noconv.} =
    if not loser.serverMilieu.runConf.inSilence:
      print_milieu("\nlocalserver", loser.serverMilieu)

    quit("\nwebdevn - shutting down...\n", 0)
  )

  if not loser.serverMilieu.runConf.inSilence:
    print_milieu("localserver", loser.serverMilieu)
  
  waitFor loser.wake_up(500)
