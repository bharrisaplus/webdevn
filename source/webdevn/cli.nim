from std/paths import Path, normalizePath, expandTilde, isAbsolute, absolutePath, splitFile
from std/parseopt import getopt, cmdArgument, cmdEnd
from std/dirs import dirExists
from std/sequtils import allIt
from std/strutils import isEmptyOrWhitespace, isDigit, parseInt, toLowerAscii, strip
from std/strformat import `&`
from std/net import Socket, newSocket, bindAddr, close
from std/nativesockets import Port

import type_defs, meta, scribe, utils

const helpManual = &"""
source lang: nim
package manager: nimble
binary version: {webdevnVersion}
dependency versions: {webdevnDependencyVersions}

Usage:
  webdevn [OPTION]

OPTION:
  What to serve:
    [-d:PATH, --dir PATH]: Location of the directory/folder that will be the base from which find requested files
    [-i:PATTERN, --index PATTERN]: Filename (with extension) of the file served when the root ('/') is requested
  How to serve:
    [-p:54321, --port 54321]: Number for which port to listen for requests on
  How to yap:
    [-v, --verbose]: Extra information about the server as it runs will be display
    [-l, --logfile]: Write information to a log file located where command is run from
                      named 'webdevn.log.txt'; can be used with verbose option.
  One-off Prints:
    [-V, --version]: Current build version, platform and dependency versions
    [-h, --help]: This message
"""


proc config_from_cli* (osCliParams: seq[string]): (webdevnConfig, seq[string]) =
  var
    cliProblems: seq[string]
    maybeConfig = defaultwebdevnConfig()

  var
    maybeIndexFile: string
    checkSocket: Socket

  for optkind, optarg, optinput in getopt(cmdline = osCliParams, shortNoVal = {'v', 'l', 'V', 'h'}, longNoVal = @["verbose", "log", "help", "version"]):
    if optkind == cmdArgument or optkind == cmdEnd:
      continue
    else: # cmdShortOption and cmdLongOption
      if optinput.isEmptyOrWhitespace() and
        optarg != "v" and optarg != "verbose" and optarg != "l" and optarg != "log" and
        optarg != "V" and optarg != "version" and optarg != "h" and optarg != "help":
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

        of "V", "version":
          scribe.printLine("webdevn verion: " & webdevnVersion)
          maybeConfig.oneOff = true
          break

        of "h", "help":
          scribe.printLine(helpManual)
          maybeConfig.oneOff = true
          break

  if not maybeConfig.oneOff:
    if maybeIndexFile == "" or maybeIndexFile == maybeConfig.indexFile:
      if not dir_contains_file(maybeConfig.basePath, maybeConfig.indexFile):
        cliProblems.add(
          &"Issue with '-i/--index' ~> IOError: Index file '{maybeConfig.indexFile}' not found within directory"
        )
    else:
      if dir_contains_file(maybeConfig.basePath, maybeIndexFile):
        maybeConfig.indexFile = maybeIndexFile
        maybeConfig.indexFileExt = splitFile(
          Path(maybeIndexFile)
        ).ext.toLowerAscii().strip(chars = {'.'})
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
  else:
    cliProblems = @[]

  return (maybeConfig, cliProblems)
