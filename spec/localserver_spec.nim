import std/unittest
from std/paths import Path, absolutePath
from std/uri import Uri, parseUri
from std/asynchttpserver import Request
from std/httpcore import HttpHeaders, Http200, Http404, `==`
from asyncdispatch import waitFor
from std/tables import `[]`
from std/strutils import startsWith, unindent, splitWhitespace, join

import ../source/webdevn/[type_defs, localserver]

let quietLoserSpecScribe = fScribe(
  willYap: false,
  doFile: false,
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

proc loserRequest (loserUri :Uri) :Request =
  return Request(
    url: loserUri
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


  test "Should have good response code if request is looked up and read successfully":
    let
      swearUrl_1 = parseUri("http://localhost:54321/")
      swearUrl_2 = parseUri("http://localhost:54321/main.css")
      swearMilieu = defaultWebdevnMilieu(
        loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_index")
      )

    let
      maybeSolution_1 = waitFor localserver.aio_for(loserRequest(swearUrl_1), swearMilieu, quietLoserSpecScribe)
      maybeSolution_2 = waitFor localserver.aio_for(loserRequest(swearUrl_2), swearMilieu, quietLoserSpecScribe)

    check:
      maybeSolution_1.responseCode == Http200
      maybeSolution_1.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]
      maybeSolution_1.responseContent.splitWhitespace().join("") == """<!DOCTYPEhtml><htmllang="en"><head><title>webdevndemo</title><metacharset="UTF-8"><metaname="viewport"content="initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no"></head><body><h2>HelloWorld</h2></body></html>"""

      maybeSolution_2.responseCode == Http200
      maybeSolution_2.responseHeaders.table["content-type"] == @["text/css; charset=utf-8"]
      maybeSolution_2.responseContent.splitWhitespace().join("") == "html{width:100%;height:100%;}body{height:calc(100%-16px);width:calc(100%-16px);margin:8px;align-content:center;justify-content:center;}h2{font-size:24px;font-weight:bold;}"


  test "Should have bad response code if request is not looked up and read successfully":
    let
      swearUrl_1 = parseUri("http://localhost:54321/")
      swearMilieu_1 = defaultWebdevnMilieu(
        loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_no_index")
      )
      swearUrl_2 = parseUri("http://localhost:54321/index.html")
      swearMilieu_2 = defaultWebdevnMilieu(
        loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_index_custom")
      )

    let
      maybeSolution_1 = waitFor localserver.aio_for(loserRequest(swearUrl_1), swearMilieu_1, quietLoserSpecScribe)
      maybeSolution_2 = waitFor localserver.aio_for(loserRequest(swearUrl_2), swearMilieu_2, quietLoserSpecScribe)

    check:
      maybeSolution_1.responseCode == Http404
      maybeSolution_1.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]

      maybeSolution_2.responseCode == Http404
      maybeSolution_2.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]
