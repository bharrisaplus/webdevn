const
  webdevnVersion* {.strdefine.} :string = "unknown"
  webdevnDependencyVersions* {.strdefine.} :string = "unknown"
  # Since read at compile time the path is relative to this file not where run from
  webdevnFavicon* :string = staticRead("assets/img/raster/icon.ico")
