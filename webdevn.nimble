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
