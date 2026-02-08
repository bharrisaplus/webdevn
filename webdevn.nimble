from std/distros import Distribution, detectOs
from std/json import JsonNode, parseJSON, keys, getStr, `[]`
from std/strformat import `&`
from std/strutils import join
from std/sugar import collect


const nimblelockJSON :string = staticRead(getEnv("PROJECT_DIR") & "/nimble.lock")
let
  nimblelockJObj :JsonNode = parseJSON(nimblelockJSON)
  nimbleDeps :seq[string] = collect:
    for nmblpkg in nimblelockJObj["packages"].keys:
      nmblpkg & "@" & nimblelockJObj["packages"][nmblpkg]["version"].getStr()


# Meta
version = "0.0.0"
author = "bharrisaplus"
description = "Webdevn: Local server for local development"
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


# Tasks

task hellon, "A task for greeting":
  echo "Hello from nimble"

task verify_version, "Compile and run the application to check version is properly set":
  let versionDefineFlag = "--define:webdevnVersion=" & version

  exec "nim r --hints:off " & versionDefineFlag & " source/webdevn.nim -V"

task verify_help, "Compile and run the application to lookover help text":
  let
    versionDefineFlag = "--define:webdevnVersion=" & version
    dependencyVersions = "--define:webdevnDependencyVersions=" & nimbleDeps.join(", ")
    defineFlags = versionDefineFlag & " " & dependencyVersions

  exec "nim r --hints:off " & defineFlags & " source/webdevn.nim -h"
