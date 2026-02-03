import std/unittest
from std/paths import Path
from std/uri import parseUri

import ../../source/webdevn/[type_defs, scribe]


let
  scribeWebdevnConfig = defaultWebdevnConfig()
  scribeWebdevnMilieu = defaultWebdevnMilieu(scribeWebdevnConfig)
  scribeUri = parseUri("http://localhost:54321/")
  scribePath = Path("./spec/appa/has_index")

suite "Scribe_BS":

  test "Should print config as expected":
    skip()
  test "Should print issues as expected":
    skip()
  test "Should print milieu as expected":
    skip()
  test "Should print lookup as expected":
    skip()
  test "Should print it as expected":
    skip()
  test "Should log when yap is true":
    let yapScribe = fScribe(willYap: true)

    yapScribe.log_config(scribeWebdevnConfig)
    yapScribe.log_issues(@["Something smells", "There's a snake in my boot"])
    yapScribe.log_milieu(scribeWebdevnMilieu)
    yapScribe.log_lookup(scribeUri, logMPath = scribePath, logDRoot = scribePath)
    yapScribe.log_it("Just some text")

    check:
      yapScribe.captured_msgs.len == 5

  test "Should not log when yap is false":
    let yapScribe = fScribe(willYap: false)

    yapScribe.log_config(scribeWebdevnConfig)
    yapScribe.log_issues(@["Something doesn't smells", "There's not a snake in my boot"])
    yapScribe.log_milieu(scribeWebdevnMilieu)
    yapScribe.log_lookup(scribeUri, logMPath = scribePath, logDRoot = scribePath)
    yapScribe.log_it("Not just some text")

    check:
      yapScribe.captured_msgs.len == 0
  test "Should spam regardless":
    let yapScribe = fScribe(willYap: true)

    yapScribe.spam_issues(@["Something smells spammy", "There's a snake in my spam"])
    yapScribe.spam_milieu(scribeWebdevnMilieu)
    yapScribe.spam_it("Just some spam")

    check:
      yapScribe.captured_msgs.len == 3

