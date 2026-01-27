import std/[sugar, times, httpcore, mimetypes]
import checksums/md5


when isMainModule:
  let m = newMimeTypes()

  var otfHeaders :seq[tuple[key: string, val: string]] = @{
    "Content-Type": m.getMimeType("html") & "; charset=utf-8",
    "Date": now().utc().format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": getMD5("Hello, World"),
  }

  var defg = newHttpHeaders(otfHeaders & @{
    "Server": "webdevn; nim/c",
    "Cache-Control": "no-cache",
    "Clear-Site-Data": "*"
  })

  dump(defg)
