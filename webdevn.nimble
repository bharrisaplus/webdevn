from std/distros import Distribution, detectOs
from system import gorgeEx
from std/strformat import `&`
from std/strutils import splitLines, split, splitWhitespace, strip, startsWith, isEmptyOrWhitespace, join

# Meta
version = "0.0.0"
author = "bharrisaplus"
description = "Web server for local development"
license = "GPLv3"


# In/ex cludes
srcDir = "source"
skipDirs = @["spec"]


# Dependencies (Used in application)
let depsNames = ["zip"] # See getPkgDeps below

## zip - To compress file contents before serving
requires "zip >= 0.3.1"


# Dev dependencies (Used in building application)

## checksums - For build distribution to determine if files have been tampered with
requires "checksums >= 0.2.1"


# Build
bin = @["webdevn"]
binDir = getEnv(key = "BUILD_OUTPUT_DIR", default = "distribution")


# Tasks

task hellon, "A task for greeting":
  echo "Hello nim"

task lint, "A task to check the main(webdevn) module for compile errors":
  exec "nim check source/webdevn.nim"

task lint_cli, "A task to check the cli module for compile errors":
  exec "nim check source/webdevn/cli.nim"

task lint_localserver, "A task to check the localserver module for compile errors":
  exec "nim check source/webdevn/localserver.nim"

task lint_scribe, "A task to check the loggo module for compile errors":
  exec "nim check source/webdevn/scribe.nim"

task lint_typeds, "A task to check the type_defs module for compile errors":
  exec "nim check source/webdevn/type_defs.nim"

task lint_utils, "A task to check the utils module for compile errors":
  exec "nim check source/webdevn/utils.nim"


# Testing

task test_cli, "Run spec for cli suite":
  exec "nim r --hints:off spec/cli_spec.nim \"Cli_BS::\""

task test_utils, "Run spec for util suite":
  exec "nim r --hints:off spec/utils_spec.nim \"Utils_BS::\""

task test_scribe, "Run spec for scribe suite":
  exec "nim r --hints:off spec/scribe_spec.nim \"Scribe_BS::\""

# Misc

# Dependent on parsing the output of nimble
proc getPkgDeps () :string =
  let (listInstalledWVersions, gorgeExitCode) = gorgeEx("nimble list -i --ver")
  var pkgNameVers: seq[string] = @[]

  if gorgeExitCode == 0:
    let listInstalledWVersionsLines = listInstalledWVersions.splitLines()
    for lineIdx, maybePkgLine in listInstalledWVersionsLines:
      if not maybePkgLine.isEmptyOrWhitespace():
        let saniLine = maybePkgLine.strip()

        if saniLine == "" or saniLine.startsWith("Warning:") or saniLine.startsWith("Info:"):
          continue

        let maybeCurrentPkg = listInstalledWVersionsLines[lineIdx - 1].strip()

        if maybeCurrentPkg in depsNames:
          if saniLine.startsWith("└── @"): # '@VERSION (CHECKSUM)' so grab between '@' and ' '
            let maybeVersion = saniLine.split('@')[1].splitWhitespace()[0]

            pkgNameVers.add(maybeCurrentPkg & "@" & maybeVersion)

    return pkgNameVers.join("; ")

task verify_version, "Compile and run the application to check version is properly set":
  let versionDefineFlag = "--define:webdevnVersion=" & version

  exec "nim r --hints:off " & versionDefineFlag & " source/webdevn.nim -V"

task verify_help, "Compile and run the application to lookover help text":
  let
    versionDefineFlag = "--define:webdevnVersion=" & version
    dependencyVersions = "--define:webdevnDependencyVersions=" & getPkgDeps()
    defineFlags = versionDefineFlag & " " & dependencyVersions

  exec "nim r --hints:off " & defineFlags & " source/webdevn.nim -h"
