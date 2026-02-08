import std/[unittest, paths, net]

import ../../source/webdevn/[cli]


suite "Cli_BS":
  let specIndex = "index.html"

  test "Should have 1 issues if no arguments provided and no index.html present":

    var
      specCmdLine:seq[string]
      (outputCliConfig, outputCliIssues) = config_from_cli(specCmdLine)

    check:
      outputCliIssues.len() == 1
      outputCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'index.html' not found within directory"


  #[test "Should have no issues if no arguments provided and index.html present":
    # Run test command from within ./spec/appa/has_index and skip all others
    # cd spec/appa/has_index && nim r ../../cli_spec.nim "CLI_BS::"
    var specCmdLine:seq[string]
    let specShortCmdLine = @["-d"]
    let specLongCmdLine = @["--dir"]

    var (outputCliConfig, outputCliIssues) = config_from_cli(specCmdLine)
    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      outputCliIssues.len() == 0
      paths.isAbsolute(outputCliConfig.basePath)
      outputCliConfig.inputPortNum == 0
      outputCliConfig.indexFile == specIndex
      outputCliConfig.inSilence

      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.inputPortNum == 0
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence

      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.inputPortNum == 0
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence
    ]#


  test "Should have no issue with relative path":
    let
      specShortCmdLine = @["-d:./spec/appa/has_index"]
      specLongCmdLine = @["--dir ", "./spec/appa/has_index"]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.inputPortNum == 0
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence


      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.inputPortNum == 0
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence


  test "Should have no issue with absolute path":
    let
      absPath = paths.absolutePath(Path("./spec/appa/has_index")).string
      specShortCmdLine = @["-d:"&absPath]
      specLongCmdLine = @["--dir ", absPath]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.inputPortNum == 0
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence


      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.inputPortNum == 0
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence


  test "Should have no issue with tilde path":
    let
      tildePath = Path("~/Bucket/bharrisaplus/webdevn/spec/appa/has_index").string
      specShortCmdLine = @["-d:"&tildePath]
      specLongCmdLine = @["--dir", tildePath]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.inputPortNum == 0
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence


      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.inputPortNum == 0
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence


  test "Should have an issue with non number value used in port":
    let
      specShortCmdLine = @["-d:./spec/appa/has_index", "-p:abc"]
      specShortCmdLine_2 = @["-d:./spec/appa/has_index", "--port", "!"]
      specLongCmdLine = @["--dir", "./spec/appa/has_index", "--port", "true"]

    var
      (_, shortCliIssues) = config_from_cli(specShortCmdLine)
      (_, shortCliIssues_2) = config_from_cli(specShortCmdLine_2)
      (_, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 1
      shortCliIssues[0] == "Issue with '-p/--port' ~> ValueError: Should be an integer"

      shortCliIssues_2.len() == 1
      shortCliIssues_2[0] == "Issue with '-p/--port' ~> ValueError: Should be an integer"

      longCliIssues.len() == 1
      longCliIssues[0] == "Issue with '-p/--port' ~> ValueError: Should be an integer"


  test "Should have an issue with non-compatible integer for port":
    let
      specOverInt = "9223372036854775808"
      specOverPort = "65536"
      specShortCmdLine = @["-d:./spec/appa/has_index", "-p:"&specOverInt]
      specShortCmdLine_2 = @["--dir", "./spec/appa/has_index", "--port", specOverPort]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (shortCliConfig_2, shortCliIssues_2) = config_from_cli(specShortCmdLine_2)

    check:
      shortCliIssues.len() == 1
      shortCliIssues[0] == "Issue with '-p/--port' ~> ValueError: Parsed integer outside of valid range"

      shortCliIssues_2.len() == 1
      shortCliIssues_2[0] == "Issue with '-p/--port' ~> ValueError: Should be 0 .. 65535"


  test "Should have 1 issue with non present index file":
    let
      specShortCmdLine = @["-d:./spec/appa/has_no_index"]
      specLongCmdLine = @["--dir", "./spec/appa/has_index_custom", "--index", "ustom.html",]
      specMixedCmdLine = @["--dir", "./spec/appa/has_index_custom"]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
      (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)

    check:
      shortCliIssues.len() == 1
      shortCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'index.html' not found within directory"

      longCliIssues.len() == 1
      longCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'ustom.html' not found within directory"

      mixedCliIssues.len() == 1
      mixedCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'index.html' not found within directory"


  test "Should be verbose based on '-v/--verbose' flag":
    let
      specShortCmdLine = @["-d:./spec/appa/has_index", "-v"]
      specLongCmdLine = @["--dir", "./spec/appa/has_index", "--verbose"]
      specMixedCmdLine = @["-d:./spec/appa/has_index", "--verbose"]
      specMissingCmdLine = @["-d:./spec/appa/has_index"]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
      (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)
      (missingCliConfig, missingCliIssues) = config_from_cli(specMissingCmdLine)

    check:
      shortCliIssues.len() == 0
      not shortCliConfig.inSilence

      longCliIssues.len() == 0
      not longCliConfig.inSilence

      mixedCliIssues.len() == 0
      not mixedCliConfig.inSilence

      missingCliIssues.len() == 0
      missingCliConfig.inSilence


  test "Should write log to file based on '-l/--logfile' flag":
    let
      specShortCmdLine = @["-d:./spec/appa/has_index", "-l"]
      specLongCmdLine = @["--dir", "./spec/appa/has_index", "--logfile"]
      specMixedCmdLine = @["-d:./spec/appa/has_index", "--logfile"]
      specMissingCmdLine = @["-d:./spec/appa/has_index"]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
      (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)
      (missingCliConfig, missingCliIssues) = config_from_cli(specMissingCmdLine)

    check:
      shortCliIssues.len() == 0
      shortCliConfig.logFile

      longCliIssues.len() == 0
      longCliConfig.logFile

      mixedCliIssues.len() == 0
      mixedCliConfig.logFile

      missingCliIssues.len() == 0
      not missingCliConfig.logFile


  test "Should prevent serving log based on '-f/--forbidlogserve' flag":
    let
      specShortCmdLine = @["-d:./spec/appa/has_index", "-f"]
      specLongCmdLine = @["--dir", "./spec/appa/has_index", "--forbidlogserve"]
      specMixedCmdLine = @["-d:./spec/appa/has_index", "--forbidlogserve"]
      specMissingCmdLine = @["-d:./spec/appa/has_index"]

    var
      (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
      (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
      (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)
      (missingCliConfig, missingCliIssues) = config_from_cli(specMissingCmdLine)

    check:
      shortCliIssues.len() == 0
      shortCliConfig.logForbidServe

      longCliIssues.len() == 0
      longCliConfig.logForbidServe

      mixedCliIssues.len() == 0
      mixedCliConfig.logForbidServe

      missingCliIssues.len() == 0
      not missingCliConfig.logForbidServe
