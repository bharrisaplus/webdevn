import std/[sugar, times, httpcore, mimetypes]
import checksums/md5

let webdevnBaseHeaders :seq[tuple[key: string, val: string]] = @{
  "Server": "webdevn; nim/c",
  "Cache-Control": "no-cache",
  "Clear-Site-Data": "*"
}

when isMainModule:
  echo "No localserver-servin happening here yet"

  let current_time = now().utc()
  let mimeLookup = newMimeTypes()

  let localserverContent = "Hello, World"

  var generatedHeaders :seq[tuple[key: string, val: string]] = @{
    "Content-Type": mimeLookup.getMimeType("html") & "; charset=utf-8",
    "Date": current_time.format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": getMD5(localserverContent),
  }

  var defg = newHttpHeaders(generatedHeaders & webdevnBaseHeaders)

  dump(defg)
