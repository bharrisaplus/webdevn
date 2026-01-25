import std/[paths, strformat]

import type_defs

proc print_config* (title: string = "webdevn", thingy: webdevnConfig) =
  var outputStr = &"{title} Config:\n"

  outputStr.add(&"  - basePath => '{thingy.basePath}'\n")
  outputStr.add(&"  - listenPort => {thingy.listenPort}\n")
  outputStr.add(&"  - indexFile => '{thingy.indexFile}'\n")
  outputStr.add(&"  - inSilence => {thingy.inSilence}\n")
  outputStr.add(&"  - writeLog => {thingy.writeLog}\n")

  echo outputStr


proc print_issues* (title: string = "webdevn", stuff: seq[string]) =
  var outputStr = &"{title} Issue(s) - [{stuff.len}]:\n"

  if stuff.len == 0:
    outputStr.add("  * No issues!\n")
  else:
    for issue in stuff:
      outputStr.add(&"  * {issue}\n")

  echo outputStr
