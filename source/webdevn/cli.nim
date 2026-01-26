import std/[paths, parseopt, dirs, sequtils, strutils, strformat, net, nativesockets]

import type_defs, utils


proc config_from_cli* (osCliParams: seq[string]): (webdevnConfig, seq[string]) =
  var cliProblems: seq[string]
  var maybeConfig = webdevnConfig(
    basePath: paths.getCurrentDir(),
    listenPort: 0.Port,
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
          if not optinput.isEmptyOrWhitespace():
            var maybeBasePath = Path(optinput)

            paths.normalizePath(maybeBasePath)

            if maybeBasePath.string[0] == '~':
              maybeBasePath = paths.expandTilde(maybeBasePath)
            elif not paths.isAbsolute(maybeBasePath):
              maybeBasePath = paths.absolutePath(maybeBasePath)

            if maybeBasePath.dirExists():
              maybeConfig.basePath = maybeBasePath

        of "p", "port": # Convert input to an int and verify within general port range
          if not optinput.isEmptyOrWhitespace() and optinput.allIt(it.isDigit()):
            try:
              var maybeListenPort = optinput.parseInt()

              if maybeListenPort > 0 and maybeListenPort <= 65535:
                maybeConfig.listenPort = maybeListenPort.Port
              else:
                cliProblems.add("Issue with '-p/--port' ~> ValueError: Should be 0 .. 65535")
            except ValueError as valE:
              cliProblems.add(&"Issue with '-p/--port' ~> {valE.name}: {valE.msg}")
          else:
            cliProblems.add("Issue with '-p/--port' ~> ValueError: Should be integer")

        of "i", "index":
          maybeIndexFile = Path(optinput)
          paths.normalizePath(maybeIndexFile)

        of "v", "verbose":
          maybeConfig.inSilence = false

        of "l", "log":
          maybeConfig.writeLog = true


  if dir_contains_file(maybeConfig.basePath, maybeIndexFile):
    maybeConfig.indexFile = maybeIndexFile
  else:
    if not dir_contains_file(maybeConfig.basePath, maybeConfig.indexFile):
      let msg = &"Index file [{maybeIndexFile},{maybeConfig.indexFile}] not found within directory"
      cliProblems.add(&"Issue with '-i/--index' ~> IOError: {msg}")

  # Check that port can be bound
  #
  try:
    checkSocket = newSocket()
    checkSocket.bindAddr(maybeConfig.listenPort)
  except OSError as osE:
    cliProblems.add(&"Issue with '-p/--port' ~> {osE.name}: {osE.msg}")
  finally:
    checkSocket.close()

  return (maybeConfig, cliProblems)
