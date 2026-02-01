# (Web)(dev)(n)im
A web server for local development. Inspired by [webfs](https://linux.bytesex.org/misc/webfs.html).

## Usage

### Help Ouput
```
$ webdevn -h
webdevn - source lang: nim
package manager: nimble
binary version: 0.0.0
dependency versions: zip@0.3.1

Usage:
  webdevn [OPTION]

OPTION:
  What to serve:
    [-d:PATH, --dir PATH]: Location of the folder that will be the base from which to find requested files
    [-i:PATTERN, --index PATTERN]: Filename (with ext) of the file served when the root ('/') is requested
  How to serve:
    [-p:54321, --port 54321]: Number for which port to listen for requests on
  How to yap:
    [-v, --verbose]: Extra information about the server as it runs will be display
    [-l, --logfile]: Write information to a log file located where command is run from
                      named 'webdevn.log.txt'; can be used with verbose option.
  One-off Prints:
    [-V, --version]: Current build version, platform and dependency versions
    [-h, --help]: This message
```

## Obtaining

### Building
