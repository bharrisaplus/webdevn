import std/os
# Meta
version = "0.0.0"
author = "bharrisaplus"
description = "Web server for local development"
license = "GPLv3"


# In/ex cludes
srcDir = "source"
skipDirs = @["spec"]


# Dependencies
requires "zip >= 0.3.1"


# Build
binDir = "distribution"


# Tasks

task hellon, "A task for greeting":
  echo "Hello nim"

task test_cli, "Run spec for cli suite":
  exec "nim r --hints:off spec/cli_spec.nim \"Cli_BS::\""
