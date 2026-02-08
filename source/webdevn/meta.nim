from std/strutils import isEmptyOrWhitespace

const
  appVersion* {.strdefine.} :string = "unknown"
  appDepVersions* {.strdefine.} :string = "unknown"
  # Since read at compile time the path is relative to this file not where run from
  webdevnFavicon* :string = staticRead("assets/img/raster/icon.ico")
  # Shorthand for cli help message
  appVersionBlurb* = if (appDepVersions == "unknown" or appDepVersions.isEmptyOrWhitespace()):
    "version: " & appVersion  
  else:
    "version: " & appVersion & "\npackage dependencies: " & appDepVersions
