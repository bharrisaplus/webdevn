from std/distros import Distribution, detectOs

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
if Distribution.Windows.detectOs():
  bin = @["webdevn"]
  binDir = "distribution/win"


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
