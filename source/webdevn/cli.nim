from std/paths import Path, normalizePath, expandTilde, isAbsolute, absolutePath, splitFile
from std/parseopt import getopt, cmdArgument, cmdEnd
from std/dirs import dirExists
from std/sequtils import allIt
from std/strutils import isEmptyOrWhitespace, isDigit, parseInt, toLowerAscii, strip
from std/strformat import `&`
from std/net import Socket, newSocket, bindAddr, close
from std/nativesockets import Port

import type_defs, meta, scribe, utils


proc config_from_cli* (osCliParams :seq[string]) :(webdevnConfig, seq[string]) =
  var
    cliProblems: seq[string]
    maybeConfig = defaultWebdevnConfig()

  var
    maybeIndexFile: string
    checkSocket: Socket

  for optkind, optarg, optinput in getopt(cmdline = osCliParams, shortNoVal = {'v', 'l', 'f', 'z', 'V', 'h'}, longNoVal = @["verbose", "logfile", "forbidlogserve", "zero", "help", "version"]):
    if optkind == cmdArgument or optkind == cmdEnd:
      continue
    else: # cmdShortOption and cmdLongOption
      if optinput.isEmptyOrWhitespace() and not (optarg in flagOpts):
        continue

      case optarg:
        of "V", "version":
          scribe.print_it("webdevn verion: " & appVersion)
          maybeConfig.oneOff = true
          break

        of "h", "help":
          scribe.print_it(helpManual)
          maybeConfig.oneOff = true
          break

        of "d", "dir": # A valid path is required
          var maybeBasePath = Path(optinput)

          normalizePath(maybeBasePath)

          if maybeBasePath.string[0] == '~':
            maybeBasePath = expandTilde(maybeBasePath)
          elif not isAbsolute(maybeBasePath):
            maybeBasePath = absolutePath(maybeBasePath)

          if maybeBasePath.dirExists():
            maybeConfig.basePath = maybeBasePath
          else:
            cliProblems.add(&"Issue with '-d/--dir' ~> Could not find path '{maybeBasePath}'")

        of "p", "port": # Convert input to an int and verify within general port range
          if optinput.allIt(it.isDigit()):
            try:
              var maybeListenPort = optinput.parseInt()

              if maybeListenPort > 0 and maybeListenPort <= 65535:
                maybeConfig.inputPortNum = maybeListenPort
              else:
                cliProblems.add("Issue with '-p/--port' ~> Should be 0 .. 65535")
            except ValueError as valE:
              cliProblems.add(&"Issue with '-p/--port' ~> {valE.name}: {valE.msg}")
          else:
            cliProblems.add("Issue with '-p/--port' ~> Should be an integer")

        of "i", "index":
          maybeIndexFile = optinput

        of "z", "zero":
          maybeConfig.zeroHost = true

        of "v", "verbose":
          maybeConfig.inSilence = false

        of "l", "logfile":
          maybeConfig.logFile = true

        of "f", "forbidlogserve":
          maybeConfig.logForbidServe = true

  if not maybeConfig.oneOff:
    if maybeIndexFile == "" or maybeIndexFile == maybeConfig.indexFile:
      if not dir_contains_file(maybeConfig.basePath, maybeConfig.indexFile):
        cliProblems.add(&"Issue with '-i/--index' ~> File '{maybeConfig.indexFile}' not found within directory")
    else:
      if dir_contains_file(maybeConfig.basePath, maybeIndexFile):
        maybeConfig.indexFile = maybeIndexFile
        maybeConfig.indexFileExt = splitFile(Path(maybeIndexFile)).ext.toLowerAscii().strip(chars = {'.'})
      else:
        cliProblems.add(&"Issue with '-i/--index' ~> File '{maybeindexFile}' not found within directory")

    # Check that port can be bound
    try:
      checkSocket = newSocket()
      checkSocket.bindAddr(Port(maybeConfig.inputPortNum))
    except OSError as osE:
      cliProblems.add(&"Issue with '-p/--port' ~> {osE.name}: {osE.msg}")
    finally:
      checkSocket.close()
  else:
    cliProblems = @[]

  return (maybeConfig, cliProblems)
