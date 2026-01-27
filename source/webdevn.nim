import std/[os]
from system import setControlCHook, quit
from std/httpcore import HttpHeaders, newHttpHeaders, `$`
from std/mimetypes import getMimeType

from checksums/md5 import getMD5

import webdevn/[type_defs, cli, utils, localserver]

when isMainModule:
  var webdevnIssues :seq[string]
  let (cliConfig, cliIssues) = configFromCLi(commandLineParams())

  if cliIssues.len > 0:
    webdevnIssues.add(cliIssues)
    print_Issues("Cli", webdevnIssues)
    quit("\nwebdevn - shutting down...\n", 0)

  let loser = newWebdevnLocalServer(webdevnMilieu(runConf: cliConfig))
  let grettingContent = "Hello, World"

  setControlCHook(proc() {.noconv.} =
    if not loser.serverMilieu.runConf.inSilence:
      print_milieu("\nlocalserver", loser.serverMilieu)

    quit("\nwebdevn - shutting down...\n", 0)
  )

  if not loser.serverMilieu.runConf.inSilence:
    print_milieu("localserver", loser.serverMilieu)

  var otfHeaders = newHttpHeaders(loser.serverMilieu.baseHeaders & mect_stamp(
    loser.mimeLookup.getMimeType(loser.serverMilieu.runConf.indexFileExt),
    getMD5(grettingContent),
    grettingContent.len
  ))

  echo "Stamped Headers: " & $otfHeaders

  echo "\nPress 'Ctrl+C' to exit"
  while true:
    discard
