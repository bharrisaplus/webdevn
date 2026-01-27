from std/httpcore import newHttpHeaders, `$`
from std/mimetypes import newMimeTypes, getMimeType
from system import debugEcho

from checksums/md5 import getMD5

import type_defs, utils


let localServerMilieu = webdevnMilieu(runConf: defaultWebdevnConfig())

when isMainModule:
  let m = newMimeTypes()

  let grettingContent = "Hello, World"

  var otfHeaders = newHttpHeaders(localServerMilieu.baseHeaders & mect_stamp(
    m.getMimeType(localServerMilieu.runConf.indexFileExt),
    getMD5(grettingContent),
    grettingContent.len
  ))

  print_milieu("localserver", localServerMilieu)
  debugEcho(otfHeaders)
