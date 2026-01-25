import std/[paths, os, parseopt, dirs, sequtils, strutils, strformat, files, net, nativesockets]

type cliConfig = object
  basePath: Path
  listenPort: int
  indexFile: Path
  inSilence: bool
  writeLog: bool

proc print_cliConfig(thingy: cliConfig) =
  var outputStr = "Cli Config:\n"

  outputStr.add(&"  - basePath => '{thingy.basePath}'\n")
  outputStr.add(&"  - listenPort => {thingy.listenPort}\n")
  outputStr.add(&"  - indexFile => '{thingy.indexFile}'\n")
  outputStr.add(&"  - inSilence => {thingy.inSilence}\n")
  outputStr.add(&"  - writeLog => {thingy.writeLog}\n")

  echo outputStr


proc print_cliConfigIssues(stuff: seq[string]) =
  var outputStr = &"Cli Issue(s) - [{stuff.len}]:\n"

  if stuff.len == 0:
    outputStr.add("  * No issues!\n")
  else:
    for issue in stuff:
      outputStr.add(&"  * {issue}\n")

  echo outputStr


proc buildCliConfig*(osCliParams: seq[string]): (cliConfig, seq[string]) =
  var parseProblems: seq[string]
  var maybeConfig = cliConfig(
    basePath: paths.getCurrentDir(),
    listenPort: 0,
    indexFile: Path("index.html"),
    inSilence: true,
    writeLog: false
  )

  var maybeIndexFile: Path
  var checkSocket: Socket

  for optkind, optarg, optinput in getopt(cmdline = osCliParams, shortNoVal = {'v', 'l'}, longNoVal = @["verbose", "log"]):
    if optkind == cmdArgument or optkind == cmdEnd:
        continue
    else: # cmdShortOption and cmdLongOption:
      case optarg: # A valid path is required
        of "d", "dir":
          var maybeBasePath = Path(optinput)

          paths.normalizePath(maybeBasePath)

          maybeBasePath = paths.expandTilde(maybeBasePath)

          if maybeBasePath.dirExists():
            maybeConfig.basePath = maybeBasePath

        of "p", "port": # Convert input to an int and verify within general port range
          if not optinput.isEmptyOrWhitespace() and optinput.allIt(it.isDigit()):
            try:
              var maybeListenPort = optinput.parseInt()

              if maybeListenPort > 0 and maybeListenPort <= 65535:
                maybeConfig.listenPort = maybeListenPort
              else:
                parseProblems.add("Issue with '-p/--port' ~> ValueError: Should be 0 .. 65535")
            except ValueError as valE:
              parseProblems.add(&"Issue with '-p/--port' ~> {valE.name}: {valE.msg}")
          else:
            parseProblems.add("Issue with '-p/--port' ~> ValueError: Should be integer")

        of "i", "index":
          maybeIndexFile = Path(optinput)
          paths.normalizePath(maybeIndexFile)

        of "v", "verbose":
          maybeConfig.inSilence = false

        of "l", "log":
          maybeConfig.writeLog = true

  # Check for index file in the basePath
  #
  if fileExists(maybeConfig.basePath / maybeIndexFile):
    maybeConfig.indexFile = maybeIndexFile
  else:
    if not fileExists(maybeConfig.basePath / maybeConfig.indexFile):
      parseProblems.add(&"Issue with '-i/--index' ~> IOError: Index file [{maybeIndexFile},{maybeConfig.indexFile}] index not found within directory"
      )

  # Check that port is available
  #
  try:
    checkSocket = newSocket()
    checkSocket.bindAddr(maybeConfig.listenPort.Port)
  except OSError as osE:
    parseProblems.add(&"Issue with '-p/--port' ~> {osE.name}: {osE.msg}")
  finally:
    checkSocket.close()

  # Output results
  #
  if not maybeConfig.inSilence:
    print_cliConfig(maybeConfig)
    print_cliConfigIssues(parseProblems)

  return (maybeConfig, parseProblems)


when isMainModule:
  discard buildCliConfig(commandLineParams())
