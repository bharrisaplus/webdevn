import std/[os]
import webdevn/[type_defs, cli, utils]

when isMainModule:
  var webdevnIssues :seq[string]
  let (cliConfig, cliIssues) = configFromCLi(commandLineParams())

  if cliIssues.len > 0:
    webdevnIssues.add(cliIssues)

  if not cliConfig.inSilence:
    print_config("Cli", cliConfig)
    print_Issues("Cli", cliIssues)
