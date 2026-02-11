from std/strutils import isEmptyOrWhitespace
from std/strformat import `&`

const
  appVersion* {.strdefine.} :string = "unknown"
  appDepVersions* {.strdefine.} :string = "unknown"
  # Since read at compile time the path is relative to this file not where run from
  webdevnFavicon* :string = staticRead("assets/img/raster/icon.ico")
  logWebDocStart* :string = staticRead("assets/doc/log_page_template/begin.html_part")
  logWebDocEnd* :string = staticRead("assets/doc/log_page_template/end.html_part")
  appVersionBlurb* = 
    if (appDepVersions == "unknown" or appDepVersions.isEmptyOrWhitespace()):
      "version: " & appVersion
    else:
      "version: " & appVersion & "\npackage dependencies: " & appDepVersions

  helpManual* = &"""
source lang: nim
package manager: nimble
{appVersionBlurb}

Usage:
  webdevn [OPTION]

OPTION[-SHORT:, --LONG]:
  What to serve:
    [-d:PATH, --dir PATH]: Location of the base folder from which to find requested files
    [-i:FILENAME, --index FILENAME]: Name (with ext) of the file served when a directory is requested
  How to serve:
    [-p:PORT, --port PORT]: Number for which port to listen for requests on
    [-z, --zero]: Use the any address 0.0.0.0 (instead of explicit localhost)
  How to yap:
    [-v, --verbose]: Extra information about the server as it runs will be logged
    [-l, --logfile]: Write logs to 'webdevn.log' within -d/--dir
    [-f, --forbidlogserve]: Returns 404 for requests of log file
  One-off Prints:
    [-V, --version]: Current build version
    [-h, --help]: This message

DEFAULTS:
  PATH: ./
  FILENAME: index.html
  PORT: 0

For short options like '-d:' be sure to include no space after the colon
"""
