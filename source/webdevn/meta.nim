from std/strutils import isEmptyOrWhitespace
from std/strformat import `&`

const
  appVersion* {.strdefine.} :string = "unknown"
  appDepVersions* {.strdefine.} :string = "unknown"
  # Since read at compile time the path is relative to this file not where run from
  webdevnFavicon* :string = staticRead("assets/img/raster/icon.ico")
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

OPTION:
  What to serve:
    [-d:PATH, --dir PATH]: Location of the base folder from which to find requested files
    [-i:PATTERN, --index PATTERN]: Filename (with ext) of the file served when a directory is requested
  How to serve:
    [-p:54321, --port 54321]: Number for which port to listen for requests on
    [-z, --zero]: Use the any address 0.0.0.0 (instead of explicit localhost)
  How to yap:
    [-v, --verbose]: Extra information about the server as it runs will be logged
    [-l, --logfile]: Write logs to 'webdevn.log' within -d/--dir
    [-f, --forbidlogserve]: Returns 404 for requests of log file
  One-off Prints:
    [-V, --version]: Current build version
    [-h, --help]: This message
"""

  # Minimal page when serving logs 
  logWebDocStart* :string = """
<!DOCTYPE html>
<html>
  <head>
    <style>
      html { height:100%; width:100%; }
      body { width:calc(100% - 16px);height:calc(100% - 16px);margin:8px;overflow:hidden; }
      #container { max-height:99%;max-width:99%;overflow:hidden; }
      #container h2 { margin-top:0; }
      #logview { font-size:14px;min-width:200px;min-height:300px;height:99%;width:99%;max-width:99%;max-height:99%;background-color:grey;overflow:scroll;resize:both; }
      #logview pre { margin:0;padding:4.5px; }
    </style>
  </head>
  <body>
    <div id="container">
      <h2>webdevn.log</h2>
      <div id="logview">
        <pre>
          <code>
"""
  logWebDocEnd* :string = """
          </code>
        </pre>
      </div>
    </div>
  </body>
</html>
"""
