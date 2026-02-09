import std/unittest
from std/paths import Path, absolutePath
from std/uri import Uri, parseUri
from std/asynchttpserver import Request
from std/httpcore import HttpHeaders, Http200, Http404, `==`
from asyncdispatch import waitFor
from std/tables import `[]`
from std/strutils import startsWith, endsWith, splitWhitespace, join

import ../../source/webdevn/[type_defs, scribe, localserver]

let quietLoserSpecScribe = mockScribe()

proc loserSpecWebDevnConfig (lBasePath :string, lIndexfile :string = "index.html") :webdevnConfig =
  return webdevnConfig(
    basePath: absolutePath(Path(lBasePath)),
    inputPortNum: 0,
    indexFile: lIndexfile,
    indexFileExt: "html",
    inSilence: true,
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

    let
        maybeSolution_1 = stamp_headers(fileExt = swearFileExt_1, fileLen = swearFileLen_1)

        maybeSolution_2 = stamp_headers(fileExt = swearFileExt_2, fileLen = swearFileLen_2)

    check:
      maybeSolution_1.table["content-type"] == @["text/html; charset=utf-8"]
      maybeSolution_2.table["content-type"] == @["image/jpeg"]


  test "Should have good response code if request is looked up and read successfully":
    let
      swearUrl_1 = parseUri("http://localhost:54321/")
      swearUrl_2 = parseUri("http://localhost:54321/main.css")
      swearFS = webdevnFS(loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_index"))

    let
      maybeSolution_1 = waitFor localserver.aio_for(loserRequest(swearUrl_1), swearFS, quietLoserSpecScribe)
      maybeSolution_2 = waitFor localserver.aio_for(loserRequest(swearUrl_2), swearFS, quietLoserSpecScribe)

    check:
      maybeSolution_1.responseCode == Http200
      maybeSolution_1.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]
      maybeSolution_1.responseContent.splitWhitespace().join("").startsWith("<!DOCTYPEhtml>")
      maybeSolution_1.responseContent.splitWhitespace().join("").endsWith("<body><h2>HelloWorld</h2></body></html>")

      maybeSolution_2.responseCode == Http200
      maybeSolution_2.responseHeaders.table["content-type"] == @["text/css; charset=utf-8"]
      maybeSolution_2.responseContent.splitWhitespace().join("").startsWith("html{width:100%;height:100%;}body")
      maybeSolution_2.responseContent.splitWhitespace().join("").endsWith("h2{font-size:24px;font-weight:bold;}")


  test "Should have bad response code if request is not looked up and read successfully":
    let
      swearUrl_1 = parseUri("http://localhost:54321/")
      swearFS_1 = webdevnFS(loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_no_index"))
      swearUrl_2 = parseUri("http://localhost:54321/index.html")
      swearFS_2 = webdevnFS(loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_index_custom"))

    let
      maybeSolution_1 = waitFor localserver.aio_for(loserRequest(swearUrl_1), swearFS_1, quietLoserSpecScribe)
      maybeSolution_2 = waitFor localserver.aio_for(loserRequest(swearUrl_2), swearFS_2, quietLoserSpecScribe)

    check:
      maybeSolution_1.responseCode == Http404
      maybeSolution_1.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]

      maybeSolution_2.responseCode == Http404
      maybeSolution_2.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]
  
  test "Should have good response code if request is for log and logs are included":
    let
      swearUrl = parseUri("http://localhost:54321/" & logName)
      swearFS = webdevnFS(loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_log"))
    
    swearFS.excludeLog = false

    let maybeSolution = waitFor localserver.aio_for(loserRequest(swearUrl), swearFS, quietLoserSpecScribe)

    check:
      maybeSolution.responseCode == Http200
      maybeSolution.responseHeaders.table["content-type"] == @["text/plain; charset=utf-8"]
      maybeSolution.responseContent == "webdevn - Starting up server"


  test "Should have bad response code if request is for log and logs are excluded":
    let
      swearUrl = parseUri("http://localhost:54321/" & logName)
      swearFS = webdevnFS(loserSpecWebDevnConfig(lBasePath = "./spec/appa/has_log"))
    
    swearFS.excludeLog = true

    let maybeSolution = waitFor localserver.aio_for(loserRequest(swearUrl), swearFS, quietLoserSpecScribe)

    check:
      maybeSolution.responseCode == Http404
      maybeSolution.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]
