from std/times import now, utc, format
from std/httpcore import newHttpHeaders, `$`
from std/mimetypes import newMimeTypes, getMimeType
from system import debugEcho

from checksums/md5 import getMD5

import type_defs


let localServerMilieu = webdevnMilieu(runConf: defaultWebdevnConfig())

when isMainModule:
  let m = newMimeTypes()

  var otfHeaders :seq[tuple[key: string, val: string]] = @{
    "Content-Type": m.getMimeType("html") & "; charset=utf-8",
    "Date": now().utc().format("ddd, dd MMM yyyy HH:mm:ss") & " GMT",
    "ETag": getMD5("Hello, World"),
  }

  var defg = newHttpHeaders(otfHeaders & localServerMilieu.baseHeaders)

  debugEcho(defg)
