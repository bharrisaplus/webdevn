from std/distros import Distribution, detectOs
from std/json import JsonNode, parseJSON, keys, getStr, `[]`
from std/strformat import `&`
from std/strutils import join
from std/sugar import collect


# Meta
version = "0.0.0"
author = "bharrisaplus"
description = "Local server for local development"
license = "GPLv3"

if version != getEnv("SEMANTIC_VERSION"):
  quit("The version needs to be updated run 'task update-saniv'", 0)


# In/ex cludes
srcDir = "source"
skipDirs = @["spec"]


## zip - To compress file contents before serving
requires "zip >= 0.3.1"


# Dev dependencies (Used in building application)
## coco - For test coverage and generting lcov info
dev:
  requires "coco >= 0.0.3"


# Helpers

let
  versionDefFlag = "--define:appVersion=" & version
  depVersionsDefFlag = "--define:appDepVersions=" & getEnv("NIMBLEPKGDEPSVER")


# Tasks

task hellon, "A task for greeting":
  echo "Hello from nimble"

task verify_version, "Compile and run the application to check version is properly set":
  exec "nim r --hints:off " & versionDefFlag & " source/webdevn.nim -V"

task verify_help, "Compile and run the application to lookover helext":
  exec "nim r --hints:off " & versionDefFlag & " " & depVersionsDefFlag & " source/webdevn.nim -h"
