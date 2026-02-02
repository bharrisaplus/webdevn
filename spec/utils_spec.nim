import std/unittest
from std/paths import Path, absolutePath, `/`
from std/net import Port
from std/uri import Uri, parseUri
from asyncdispatch import waitFor
from std/strutils import startsWith, unindent

import ../source/webdevn/[type_defs, utils]


let quietUtilSpecScribe = fScribe(
  willYap: false,
  doFile: false,
  maxRotate: 0,
  logPath: Path(""),
  logName: ""
)

proc utilSpecLookupParts (drStr :string) :lookupParts =
  return (
    docRoot: absolutePath(Path(drStr)),
    docIndex: "index.html",
    docIndexExt: "html"
  )


suite "Utils_BS":

  test "Should be true if filename pattern is within the directory":
    let
      swearPath = absolutePath(Path("./spec/appa/has_index"))
      swearFile = "index.html"

    check:
      utils.dir_contains_file(maybeParent = swearPath, maybeChild = swearFile)


  test "Should be false if filename pattern is not within directory":
    let
      swearPath = absolutePath(Path("./spec/appa/has_no_index"))
      swearFile = "index.html"

    check:
      not utils.dir_contains_file(maybeParent = swearPath, maybeChild = swearFile)


  test "Should have no issues if requested file is within document root":
    let
      swearUrl_1 = parseUri("http://localhost:54321/")
      swearUrl_2 = parseUri("http://localhost:54321/main.css")
      swearLookupParts = utilSpecLookupParts("./spec/appa/has_index")

    let
      maybeSolution_1 = lookup_from_url(
        virtualFs = swearLookupParts, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_1
      )
      
      maybeSolution_2 = lookup_from_url(
        virtualFs = swearLookupParts, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_2
      )

    check:
      maybeSolution_1.issues.len == 0
      maybeSolution_1.loc == (swearLookupParts.docRoot / Path(swearLookupParts.docIndex)).string
      maybeSolution_1.ext == swearLookupParts.docIndexExt

      maybeSolution_2.issues.len == 0
      maybeSolution_2.loc == (swearLookupParts.docRoot / Path("main.css")).string
      maybeSolution_2.ext == "css"


  test "Should have 1 issue if requested file is not within document root":
    let
      swearUrl_1 = parseUri("http://localhost:54321/")
      swearUrl_2 = parseUri("http://localhost:54321/main.js")
      swearLookupParts = utilSpecLookupParts("./spec/appa/has_no_index")

    let
      maybeSolution_1 = lookup_from_url(
        virtualFs = swearLookupParts, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_1
      )
      
      maybeSolution_2 = lookup_from_url(
        virtualFs = swearLookupParts, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_2
      )

    check:
      maybeSolution_1.issues.len == 1
      maybeSolution_2.issues.len == 1


  test "Should have no issues if requested file is within safeSearch scope":
    let
      swearUrl_1a = parseUri("http://localhost:54321/scripts/main.js")
      swearUrl_1b = parseUri("http://localhost:54321/../src/js/source.js")
      swearLookupParts_1 = utilSpecLookupParts("./spec/appa/example_safesearch/dist")

    let
      swearUrl_2a = parseUri("http://localhost:54321/stylesheets/main.css")
      swearUrl_2b = parseUri("http://localhost:54321/../../node_modules/somepkg/somethingsomething_npm.bundle.css")
      swearLookupParts_2 = utilSpecLookupParts("./spec/appa/example_safesearchnode/dist/asite")

    let
      maybeSolution_1a = lookup_from_url(
        virtualFs = swearLookupParts_1, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_1a
      )
      
      maybeSolution_1b = lookup_from_url(
        virtualFs = swearLookupParts_1, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_1b
      )
      
      maybeSolution_2a = lookup_from_url(
        virtualFs = swearLookupParts_2, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_2a
      )
      
      maybeSolution_2b = lookup_from_url(
        virtualFs = swearLookupParts_2, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_2b
      )


    check:
      maybeSolution_1a.issues.len == 0
      maybeSolution_1a.loc == (swearLookupParts_1.docRoot / Path("scripts/main.js")).string
      maybeSolution_1a.ext == "js"
      maybeSolution_1b.issues.len == 0
      maybeSolution_1b.loc == (swearLookupParts_1.docRoot / Path("../src/js/source.js")).string
      maybeSolution_1b.ext == "js"

      maybeSolution_2a.issues.len == 0
      maybeSolution_2a.loc == (swearLookupParts_2.docRoot / Path("stylesheets/main.css")).string
      maybeSolution_2a.ext == "css"
      maybeSolution_2b.issues.len == 0
      maybeSolution_2b.loc == (swearLookupParts_2.docRoot / Path("../../node_modules/somepkg/somethingsomething_npm.bundle.css")).string
      maybeSolution_2b.ext == "css"


  test "Should have 1 issue if requested file is not within safeSearch scope":
    let
      swearUrl_1a = parseUri("http://localhost:54321/stylesheets/main.css")
      swearUrl_1b = parseUri("http://localhost:54321/../src/css/source.cs")
      swearLookupParts_1 = utilSpecLookupParts("./spec/appa/example_safesearch/dist")

    let
      swearUrl_2a = parseUri("http://localhost:54321/scripts/main.js")
      swearUrl_2b = parseUri("http://localhost:54321/../../node_modules/somepkg/somethingsomething_npm.bundle.js")
      swearLookupParts_2 = utilSpecLookupParts("./spec/appa/example_safesearchnode/dist/asite")

    let
      maybeSolution_1a = lookup_from_url(
        virtualFs = swearLookupParts_1, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_1a
      )
      maybeSolution_1b = lookup_from_url(
        virtualFs = swearLookupParts_1, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_1b
      )
      maybeSolution_2a = lookup_from_url(
        virtualFs = swearLookupParts_2, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_2a
      )
      maybeSolution_2b = lookup_from_url(
        virtualFs = swearLookupParts_2, urlScribe = quietUtilSpecScribe, reqUrl = swearUrl_2b
      )

    check:
      maybeSolution_1a.issues.len == 1
      maybeSolution_1b.issues.len == 1

      maybeSolution_2a.issues.len == 1
      maybeSolution_2b.issues.len == 1


  test "Should have no issues if file is read successfully":
    let swearMorsel = absolutePath(Path("./spec/appa/has_index/index.html")).string

    let maybeSolution = waitFor lazy_gobble(gobbleScribe = quietUtilSpecScribe, morsel = swearMorsel)

    check:
      maybeSolution.issues.len == 0
      maybeSolution.contents == (
        """<!DOCTYPE html>
        <html lang="en">
          <head>
            <title>webdevn demo</title>
            <meta charset="UTF-8">
            <meta name="viewport" content="initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
          </head>
          <body>
            <h2>Hello World</h2>
          </body>
        </html>
        """
      ).unindent(count = 8)

  test "Should have 1 issue if file is not found when attempting to read":
    let swearMorsel = absolutePath(Path("./spec/appa/has_index/about.html")).string

    let maybeSolution = waitFor lazy_gobble(gobbleScribe = quietUtilSpecScribe, morsel = swearMorsel)

    check:
      maybeSolution.issues.len == 1
      maybeSolution.issues[0].startsWith("OS")
