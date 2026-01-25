import std/[os]
import webdevn/[type_defs, cli, utils]

when isMainModule:
  var webdevnIssues: seq[string]
  let (webdevnCliConfig, cliIssues) = configFromCLi(commandLineParams())

  if cliIssues.len > 0:
    webdevnIssues.add(cliIssues)

  if not webdevnCliConfig.inSilence:
    print_config("Cli", webdevnCliConfig)
    print_Issues("Cli", webdevnIssues)
