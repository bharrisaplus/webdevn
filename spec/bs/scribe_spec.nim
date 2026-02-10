import std/unittest
from std/paths import Path
from std/uri import parseUri
from std/strutils import startsWith, endsWith, contains

import ../../source/webdevn/[type_defs, scribe]


let
  scribeWebdevnConfig = defaultWebdevnConfig()
  scribeWebdevnMilieu = defaultWebdevnMilieu(scribeWebdevnConfig)
  scribeUri = parseUri("http://localhost:54321/")
  scribePath = Path("./spec/appa/has_index")

suite "Scribe_BS":

  test "Should print issues as expected":
    let
      maybeSolution_1 = scribe.fmt_print_issues(@[])
      maybeSolution_2 = scribe.fmt_print_issues(@["Black Jack", "Here we go again"])

    check:
      maybeSolution_1.startsWith("webdevn - issue(s) [0]:\n")
      maybeSolution_1.endsWith("  * No issues!\n")

      maybeSolution_2.startsWith("webdevn - issue(s) [2]:\n")
      maybeSolution_2.contains("  * Black Jack\n")
      maybeSolution_2.endsWith("  * Here we go again\n")


  test "Should print milieu as expected":
    let maybeSolution = $scribeWebdevnMilieu

    check:
      maybeSolution.startsWith("webdevn - milieu:\n")
      maybeSolution.contains("  - docIndex => index.html\n")
      maybeSolution.endsWith("  - listenPort => 0\n")


  test "Should print lookup as expected":
    let maybeSolution = fmt_print_lookup(scribeUri, mPath = scribePath, dRoot = scribePath)

    check:
      maybeSolution.startsWith("webdevn - request lookup:\n")
      maybeSolution.contains("  - Request URL Path: /\n")
      maybeSolution.endsWith("  - basePath-Parent-Parent: spec\n")


  test "Should print it as expected":
    let maybeSolution = scribe.fmt_print_it("A log for log's sake")

    check:
      maybeSolution.startsWith("webdevn - ")
      maybeSolution.endsWith("sake")


  test "Should log when yap is true":
    let yapScribe = mockScribe(verbose = true)

    yapScribe.log_issues(@["Something smells", "There's a snake in my boot"])
    yapScribe.log_milieu(scribeWebdevnMilieu)
    yapScribe.log_lookup(scribeUri, logMPath = scribePath, logDRoot = scribePath)
    yapScribe.log_it("Just some text")

    check:
      yapScribe.captured_msgs.len == 4


  test "Should not log when yap is false":
    let yapScribe = mockScribe()

    yapScribe.log_issues(@["Something doesn't smells", "There's not a snake in my boot"])
    yapScribe.log_milieu(scribeWebdevnMilieu)
    yapScribe.log_lookup(scribeUri, logMPath = scribePath, logDRoot = scribePath)
    yapScribe.log_it("Not just some text")

    check:
      yapScribe.captured_msgs.len == 0


  test "Should spam regardless":
    let yapScribe = mockScribe(verbose = true)

    yapScribe.spam_issues(@["Something smells spammy", "There's a snake in my spam"])
    yapScribe.spam_milieu(scribeWebdevnMilieu)
    yapScribe.spam_it("Just some spam")

    check:
      yapScribe.captured_msgs.len == 3
