import std/unittest
from std/paths import Path, absolutePath
from std/net import Port
from std/httpcore import HttpHeaders, `$`
from std/strformat import `&`
from std/tables import `[]`

import ../source/webdevn/[type_defs, localserver]

let quietLoserSpecScribe = fScribe(
  willYap: false,
  doFile: false,
  rotateFile: false,
  maxRotate: 0,
  logPath: Path(""),
  logName: ""
)

proc loserSpecWebDevnConfig (lBasePath :string, lIndexfile :string = "index.html") :webdevnConfig =
  return webdevnConfig(
    basePath: absolutePath(Path(lBasePath)),
    inputPortNum: 0,
    indexFile: lIndexfile,
    indexFileExt: "html",
    inSilence: true,
    writeLog: false,
    zeroHost: false
  )


suite "LocalServer_BS":

  test "Should make stamped headers":
    let
      swearFileExt_1 = "html"
      swearFileLen_1 = 0
      swearFileExt_2 = "jpg"
      swearFileLen_2 = 0
      swearMilieu = defaultWebdevnMilieu(
        loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_index")
      )

    let
        maybeSolution_1 = stamp_headers(
          fileExt = swearFileExt_1, fileLen = swearFileLen_1, stampMilieu = swearMilieu,
        )

        maybeSolution_2 = stamp_headers(
          fileExt = swearFileExt_2, fileLen = swearFileLen_2, stampMilieu = swearMilieu,
        )

    check:
      maybeSolution_1.table["content-type"] == @["text/html; charset=utf-8"]
      maybeSolution_2.table["content-type"] == @["image/jpeg"]
