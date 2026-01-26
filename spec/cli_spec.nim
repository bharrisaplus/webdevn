import std/[unittest, paths, net]

import ../source/webdevn/[cli]

suite "Cli_BS":
  let specPort = 0.Port
  let specIndex = "index.html"

  test "Should have 1 issues if no arguments provided and no index.html present":

    var specCmdLine:seq[string]

    var (outputCliConfig, outputCliIssues) = config_from_cli(specCmdLine)

    check:
      outputCliIssues.len() == 1
      outputCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'index.html' not found within directory"


  #[test "Should have no issues if no arguments provided and index.html present":
    # Run test command from within ./appa/has_index and skip all others
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
      outputCliConfig.listenPort == specPort
      outputCliConfig.indexFile == specIndex
      outputCliConfig.inSilence
      not outputCliConfig.writeLog

      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.listenPort == specPort
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence
      not shortCliConfig.writeLog

      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.listenPort == specPort
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence
      not longCliConfig.writeLog
    ]#


  test "Should have no issue with relative path":
    let specShortCmdLine = @["-d:./spec/appa/has_index"]
    let specLongCmdLine = @["--dir ", "./spec/appa/has_index"]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.listenPort == specPort
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence
      not shortCliConfig.writeLog


      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.listenPort == specPort
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence
      not longCliConfig.writeLog


  test "Should have no issue with absolute path":
    let absPath = paths.absolutePath(Path("./spec/appa/has_index")).string
    let specShortCmdLine = @["-d:"&absPath]
    let specLongCmdLine = @["--dir ", absPath]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.listenPort == specPort
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence
      not shortCliConfig.writeLog


      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.listenPort == specPort
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence
      not longCliConfig.writeLog


  test "Should have no issue with tilde path":
    #skip()
    let tildePath = Path("~/Bucket/bharrisaplus/webdevn/spec/appa/has_index").string
    let specShortCmdLine = @["-d:"&tildePath]
    let specLongCmdLine = @["--dir", tildePath]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 0
      paths.isAbsolute(shortCliConfig.basePath)
      shortCliConfig.listenPort == specPort
      shortCliConfig.indexFile == specIndex
      shortCliConfig.inSilence
      not shortCliConfig.writeLog


      longCliIssues.len() == 0
      paths.isAbsolute(longCliConfig.basePath)
      longCliConfig.listenPort == specPort
      longCliConfig.indexFile == specIndex
      longCliConfig.inSilence
      not longCliConfig.writeLog


  test "Should have an issue with non number value used in port":
    let specShortCmdLine = @["-d:./spec/appa/has_index", "-p:abc"]
    let specShortCmdLine_2 = @["-d:./spec/appa/has_index", "--port", "!"]
    let specLongCmdLine = @["--dir", "./spec/appa/has_index", "--port", "true"]

    var (_, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (_, shortCliIssues_2) = config_from_cli(specShortCmdLine_2)
    var (_, longCliIssues) = config_from_cli(specLongCmdLine)

    check:
      shortCliIssues.len() == 1
      shortCliIssues[0] == "Issue with '-p/--port' ~> ValueError: Should be an integer"

      shortCliIssues_2.len() == 1
      shortCliIssues_2[0] == "Issue with '-p/--port' ~> ValueError: Should be an integer"

      longCliIssues.len() == 1
      longCliIssues[0] == "Issue with '-p/--port' ~> ValueError: Should be an integer"


  test "Should have an issue with non-compatible integer for port":
    let specOverInt = "9223372036854775808"
    let specOverPort = "65536"
    let specShortCmdLine = @["-d:./spec/appa/has_index", "-p:"&specOverInt]
    let specShortCmdLine_2 = @["--dir", "./spec/appa/has_index", "--port", specOverPort]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (shortCliConfig_2, shortCliIssues_2) = config_from_cli(specShortCmdLine_2)

    check:
      shortCliIssues.len() == 1
      shortCliIssues[0] == "Issue with '-p/--port' ~> ValueError: Parsed integer outside of valid range"

      shortCliIssues_2.len() == 1
      shortCliIssues_2[0] == "Issue with '-p/--port' ~> ValueError: Should be 0 .. 65535"


  test "Should have 1 issue with non present index file":
    let specShortCmdLine = @["-d:./spec/appa/has_no_index"]
    let specLongCmdLine = @["--dir", "./spec/appa/has_index_custom", "--index", "ustom.html",]
    let specMixedCmdLine = @["--dir", "./spec/appa/has_index_custom"]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
    var (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)

    check:
      shortCliIssues.len() == 1
      shortCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'index.html' not found within directory"

      longCliIssues.len() == 1
      longCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'ustom.html' not found within directory"

      mixedCliIssues.len() == 1
      mixedCliIssues[0] == "Issue with '-i/--index' ~> IOError: Index file 'index.html' not found within directory"


  test "Should be verbose with flag present":
    let specShortCmdLine = @["-d:./spec/appa/has_index", "-v"]
    let specLongCmdLine = @["--dir", "./spec/appa/has_index", "--verbose"]
    let specMixedCmdLine = @["-d:./spec/appa/has_index", "--verbose"]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
    var (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)

    check:
      shortCliIssues.len() == 0
      not shortCliConfig.inSilence

      longCliIssues.len() == 0
      not longCliConfig.inSilence

      mixedCliIssues.len() == 0
      not mixedCliConfig.inSilence


  test "Should write logfile with flag present":
    let specShortCmdLine = @["-d:./spec/appa/has_index", "-l"]
    let specLongCmdLine = @["--dir", "./spec/appa/has_index", "--log"]
    let specMixedCmdLine = @["--dir", "./spec/appa/has_index", "-l"]

    var (shortCliConfig, shortCliIssues) = config_from_cli(specShortCmdLine)
    var (longCliConfig, longCliIssues) = config_from_cli(specLongCmdLine)
    var (mixedCliConfig, mixedCliIssues) = config_from_cli(specMixedCmdLine)

    check:
      shortCliIssues.len() == 0
      shortCliConfig.writeLog

      longCliIssues.len() == 0
      longCliConfig.writeLog

      mixedCliIssues.len() == 0
      mixedCliConfig.writeLog
