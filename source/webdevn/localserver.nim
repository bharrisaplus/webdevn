from std/mimetypes import getMimeType
from std/asyncfutures import Future, newFuture, complete
from std/asyncmacro import `async`, `await`
from std/strutils import startsWith, endsWith
from std/times import now, utc, format
from std/strformat import fmt, `&`
from std/nativesockets import `$`
from std/net import Port, `$`
from std/httpcore import HttpHeaders, HttpCode, Http200, Http404, newHttpHeaders, `$`
from std/asynchttpserver import AsyncHttpServer, Request, listen, getPort

import meta, type_defs, scribe, utils


# Runtime environment

type Milieu* = object
  virtualFS :webFS
  listenPort :Port
  anyAddr :bool

proc webdevnMilieu* (someConfig :webdevnConfig) :Milieu =
  return Milieu(
    virtualFS: webdevnFS(someConfig),
    listenPort: Port(someConfig.inputPortNum),
    anyAddr: someConfig.zeroHost
  )


proc `$`* (someMilieu :Milieu) :string =
  return fmt"""
webdevn - milieu:
  - docRoot => {someMilieu.virtualFS.docRoot}
  - docIndex => {someMilieu.virtualFS.docIndex}
  - docIndexExt => {someMilieu.virtualFS.docIndexExt}
  - listenPort => {someMilieu.listenPort}
"""



proc stamp_headers* (fileExt :string, fileLen :int) :HttpHeaders =
  let mimeType = mimeLookup.getMimeType(fileExt)

  let textLike = mimeType.startsWith("text/") or mimeType == "application/javascript" or
    mimeType == "application/json" or mimeType.endsWith("+xml")

  let
    contentEncoding = if textLike: "; charset=utf-8" else: ""
    currentTime = now().utc()

  return newHttpHeaders(baseHeaderBits & @{
    "Content-Type": mimeType & contentEncoding,
    "Content-Length": $fileLen,
    "Date": currentTime.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": "W/\"" & currentTime.format("ddMMyyHHmmss") & "-" & $fileLen
  })


proc spawn_daemon* (envv :Milieu, netHandle :AsyncHttpServer, spawnScribe :aScribe) :seq[string] =
  let listenAddress = if envv.anyAddr: "0.0.0.0" else: "localhost"
  var spawnIssues :seq[string] = @[]

  try:
    netHandle.listen(address = listenAddress, port = envv.listenPort)
    spawnScribe.spam_it("Starting up server")
    spawnScribe.spam_it("Listening on " & listenAddress & ":" & $netHandle.getPort)
  except OSError as osE:
    spawnIssues.add(&"OS happenings while starting the server:\n    {osE.name}: {osE.msg}")
  except Exception as bigE:
    spawnIssues.add(&"Something occured while starting the server:\n    {bigE.name}: {bigE.msg}")

  return spawnIssues


proc aio_for* (aioReq :Request, envv :Milieu, aioScribe :aScribe) :Future[aioResponse] {.async.} =
  let lookupInfo = lookup_from_url(aioReq.url, envv.virtualFS, aioScribe)

  var
    resContent :string
    resCode :HttpCode
    resHeaders :HttpHeaders
    isOk :bool

  if lookupInfo.issues.len == 0:
    isOk = true
  else:
    aioScribe.log_issues(lookupInfo.issues)

  if isOk:
    let gobbleInfo = await lazy_gobble(lookupInfo.loc, aioScribe)

    if gobbleInfo.issues.len == 0:
      aioScribe.log_it(&"(200) Found File")
      resContent = gobbleInfo.contents
      resCode = Http200
      resHeaders = stamp_headers(lookupInfo.ext, resContent.len)

    else:
      aioScribe.log_issues(gobbleInfo.issues)
      isOk = false

  if not isOk:
    if aioReq.url.path == "/favicon.ico": # Use fallback favicon
      aioScribe.log_it("Using fallback for missing favicon.ico")
      resContent = webdevnFavicon
      resCode = Http200
      resHeaders = newHttpHeaders(faviconHeaderBits)
    else:
      aioScribe.log_it(&"(404) File Not Found")
      resContent = notFoundContent
      resCode = Http404
      resHeaders = stamp_headers( "html", resContent.len)

  aioScribe.log_it(&"Stamped Headers: {resHeaders}")
  aioScribe.spam_it(&"Responding to request: {aioReq.url}\n=============")

  return (responseCode: resCode, responseContent: resContent, responseHeaders: resHeaders)
