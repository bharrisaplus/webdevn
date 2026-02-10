import std/unittest
from std/paths import Path, absolutePath
from std/uri import Uri, parseUri
from std/asynchttpserver import Request, newAsyncHttpServer, close, listen
from std/httpcore import HttpHeaders, Http200, Http404, `==`
from asyncdispatch import waitFor
from std/tables import `[]`
from std/strutils import startsWith, endsWith, splitWhitespace, join
from std/os import sleep
from std/net import Port, newSocket, connect, close, bindAddr
from std/strformat import `&`

import ../../source/webdevn/[type_defs, scribe, localserver]


let quietLoserSpecScribe = mockScribe()

proc loserSpecMilieu (lBasePath = "./spec/appa/has_index", lIndexfile = "index.html", lNoServLog = false, lPort = 0, lZero = false) :milieu =
  return webdevnMilieu(webdevnConfig(
    basePath: absolutePath(Path(lBasePath)),
    indexFile: lIndexfile,
    indexFileExt: "html",
    logForbidServe: lNoServLog,
    inputPortNum: lPort,
    zeroHost: lZero
  ))


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
      swearMilieu = loserSpecMilieu()

    let
      maybeSolution_1 = waitFor localserver.aio_for(Request(url: swearUrl_1), swearMilieu, quietLoserSpecScribe)
      maybeSolution_2 = waitFor localserver.aio_for(Request(url: swearUrl_2), swearMilieu, quietLoserSpecScribe)

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
      swearMilieu_1 = loserSpecMilieu(lbasePath = "./spec/appa/has_no_index")
      swearUrl_2 = parseUri("http://localhost:54321/index.html")
      swearMilieu_2 = loserSpecMilieu(lbasePath = "./spec/appa/has_index_custom")

    let
      maybeSolution_1 = waitFor localserver.aio_for(Request(url: swearUrl_1), swearMilieu_1, quietLoserSpecScribe)
      maybeSolution_2 = waitFor localserver.aio_for(Request(url: swearUrl_2), swearMilieu_2, quietLoserSpecScribe)

    check:
      maybeSolution_1.responseCode == Http404
      maybeSolution_1.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]

      maybeSolution_2.responseCode == Http404
      maybeSolution_2.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]


  test "Should have good response code if request is for log and logs are included":
    let
      swearUrl = parseUri("http://localhost:54321/" & logName)
      swearMilieu = loserSpecMilieu(lBasePath = "./spec/appa/has_log")

    let maybeSolution = waitFor localserver.aio_for(Request(url: swearUrl), swearMilieu, quietLoserSpecScribe)

    check:
      maybeSolution.responseCode == Http200
      maybeSolution.responseHeaders.table["content-type"] == @["text/plain; charset=utf-8"]
      maybeSolution.responseContent == "webdevn - Starting up server"


  test "Should have bad response code if request is for log and logs are excluded":
    let
      swearUrl = parseUri("http://localhost:54321/" & logName)
      swearMilieu = loserSpecMilieu(lBasePath = "./spec/appa/has_log", lNoServLog = true)

    let maybeSolution = waitFor localserver.aio_for(Request(url: swearUrl), swearMilieu, quietLoserSpecScribe)

    check:
      maybeSolution.responseCode == Http404
      maybeSolution.responseHeaders.table["content-type"] == @["text/html; charset=utf-8"]

  test "Should have no issues spawning daemon":
    let
      loserSpecServer = newAsyncHttpServer(reuseAddr = false, reusePort = false)
      swearPort = 54321
      swearAddr = "localhost"
      swearMilieu = loserSpecMilieu(lPort = swearPort)

    let maybeIssues = localserver.spawn_daemon(swearMilieu, loserSpecServer, quietLoserSpecScribe)

    sleep(54)

    let specClient = newSocket()
    var wasAwakened = false

    try:
      specClient.connect(address = swearAddr, port = Port(swearPort), timeout = 500)
      wasAwakened = true
    except OSError as osE:
      echo &"{osE.name}: {osE.msg}"
    except CatchableError as catE:
      echo &"{catE.name}: {catE.msg}"
    finally:
      specClient.close()
      loserSpecServer.close()

    check:
      wasAwakened
      maybeIssues.len == 0


  test "Extra: Should have 1 issue if can not spawn daemon":
    let
      hogSocket = newSocket()
      loserSpecServer = newAsyncHttpServer(reuseAddr = false, reusePort = false)
      swearPort = 54321
      swearAddr = "localhost"
      swearMilieu = loserSpecMilieu(lPort = swearPort)

    try:
      hogSocket.bindAddr(address = swearAddr, port = Port(swearPort))
    except OSError as osE:
      echo &"Unable to bind port for test ~> {osE.name}: {osE.msg}"

    let maybeIssues = localserver.spawn_daemon(swearMilieu, loserSpecServer, quietLoserSpecScribe)
    var wasAwakened = false

    hogSocket.close()
    loserSpecServer.close()

    check:
      not wasAwakened
      maybeIssues.len == 1
