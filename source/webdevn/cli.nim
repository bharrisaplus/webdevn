from std/paths import Path, normalizePath, expandTilde, isAbsolute, absolutePath, splitFile
from std/parseopt import getopt, cmdArgument, cmdEnd
from std/dirs import dirExists
from std/sequtils import allIt
from std/strutils import isEmptyOrWhitespace, isDigit, parseInt, toLowerAscii, strip
from std/strformat import `&`
from std/net import Socket, newSocket, bindAddr, close
from std/nativesockets import Port

import type_defs, utils


proc config_from_cli* (osCliParams: seq[string]): (webdevnConfig, seq[string]) =
  var cliProblems: seq[string]
  var maybeConfig = webdevnConfig(
    basePath: paths.getCurrentDir(),
    listenPort: 0.Port,
    indexFile: "index.html",
    inSilence: true,
    writeLog: false
  )

  var maybeIndexFile: string
  var checkSocket: Socket

  for optkind, optarg, optinput in getopt(cmdline = osCliParams, shortNoVal = {'v', 'l'}, longNoVal = @["verbose", "log"]):
    if optkind == cmdArgument or optkind == cmdEnd:
      continue
    else: # cmdShortOption and cmdLongOption
      if optinput.isEmptyOrWhitespace() and optarg != "v" and optarg != "verbose" and optarg != "l" and optarg != "log":
        continue

      case optarg: # A valid path is required
        of "d", "dir":
          var maybeBasePath = Path(optinput)

          normalizePath(maybeBasePath)

          if maybeBasePath.string[0] == '~':
            maybeBasePath = expandTilde(maybeBasePath)
          elif not isAbsolute(maybeBasePath):
            maybeBasePath = absolutePath(maybeBasePath)

          if maybeBasePath.dirExists():
            maybeConfig.basePath = maybeBasePath
          else:
            cliProblems.add(
              &"Issue with '-d/--dir' ~> IOError: Could not find path '{maybeBasePath}'"
            )

        of "p", "port": # Convert input to an int and verify within general port range
          if optinput.allIt(it.isDigit()):
            try:
              var maybeListenPort = optinput.parseInt()

              if maybeListenPort > 0 and maybeListenPort <= 65535:
                maybeConfig.listenPort = maybeListenPort.Port
              else:
                cliProblems.add("Issue with '-p/--port' ~> ValueError: Should be 0 .. 65535")
            except ValueError as valE:
              cliProblems.add(&"Issue with '-p/--port' ~> {valE.name}: {valE.msg}")
          else:
            cliProblems.add("Issue with '-p/--port' ~> ValueError: Should be an integer")

        of "i", "index":
          maybeIndexFile = optinput

        of "v", "verbose":
          maybeConfig.inSilence = false

        of "l", "log":
          maybeConfig.writeLog = true


  if maybeIndexFile == "" or maybeIndexFile == maybeConfig.indexFile:
    if not dir_contains_file(maybeConfig.basePath, maybeConfig.indexFile):
      cliProblems.add(
        &"Issue with '-i/--index' ~> IOError: Index file '{maybeConfig.indexFile}' not found within directory"
      )
  else:
    if dir_contains_file(maybeConfig.basePath, maybeIndexFile):
      maybeConfig.indexFile = maybeIndexFile
    else:
      cliProblems.add(
        &"Issue with '-i/--index' ~> IOError: Index file '{maybeindexFile}' not found within directory"
      )

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
