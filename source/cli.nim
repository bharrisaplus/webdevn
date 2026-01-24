import std/[paths, os, parseopt, dirs, sequtils, strutils, strformat, files, net, nativesockets, sugar]

type cliOptions = object
  basePath: Path
  listenPort: int
  indexFile: Path
  inSilence: bool
  writeLog: bool


proc getCliOptions(osCliParams: seq[string]): (cliOptions, seq[string]) =
  var parseProblems: seq[string]
  var maybeOptions = cliOptions(
    basePath: paths.getCurrentDir(),
    listenPort: 0,
    indexFile: Path("index.html"),
    inSilence: true,
    writeLog: false
  )

  var maybeIndexFile: Path
  var checkSocket: Socket

  for optkind, optarg, optinput in parseopt.getopt(cmdline = osCliParams, shortNoVal = {'v', 'l'}, longNoVal = @["verbose", "log"]):
    if optkind == cmdArgument or optkind == cmdEnd:
        discard
    else: # cmdShortOption and cmdLongOption:
      case optarg: # A valid path is required
        of "d", "dir":
          var maybeBasePath = Path(optinput)

          paths.normalizePath(maybeBasePath)

          maybeBasePath = paths.expandTilde(maybeBasePath)

          if dirs.dirExists(maybeBasePath):
            maybeOptions.basePath = maybeBasePath

        of "p", "port": # Convert input to an int and verify within general port range
          if not strutils.isEmptyOrWhitespace(optinput) and optinput.allIt(strutils.isDigit(it)):
            try:
              var maybeListenPort = strutils.parseInt(optinput)
              if maybeListenPort > 0 and maybeListenPort < 65535:
                maybeOptions.listenPort = maybeListenPort
            except ValueError as vE:
              parseProblems.add(strformat.fmt"Issue with '-p/--port' ~> {vE.name}: {vE.msg}")
          else:
            parseProblems.add(
              "Issue with '-p/--port' ~> Value should be integer representing port (0 - 65535)"
            )

        of "i", "index":
          maybeIndexFile = Path(optinput)
          paths.normalizePath(maybeIndexFile)

        of "v", "verbose":
          maybeOptions.inSilence = false

        of "l", "log":
          maybeOptions.writeLog = true

  # Check for index file in the basePath
  #
  if files.fileExists(maybeOptions.basePath / maybeIndexFile):
    maybeOptions.indexFile = maybeIndexFile
  else:
    if not files.fileExists(maybeOptions.basePath / maybeOptions.indexFile):
      parseProblems.add(
        "Issue with '-i/--index' ~> IOError: Index file, index not found within directory, -d/--dir"
      )

  # Check that port is available
  #
  try:
    checkSocket = net.newSocket()
    checkSocket.bindAddr(maybeOptions.listenPort.Port)
  except OSError as osE:
    parseProblems.add(&"Issue with '-p/--port' ~> {osE.name}: {osE.msg}")
  finally:
    checkSocket.close()

  return (maybeOptions, parseProblems)

let cliOptionsResult = getCliOptions(os.commandLineParams())

dump(cliOptionsResult[0])
dump(cliOptionsResult[1])
