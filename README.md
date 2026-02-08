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
    [-d:PATH, --dir PATH]: Location of the base folder from which to find requested files
    [-i:PATTERN, --index PATTERN]: Filename (with ext) of the file served when a directory is requested
  How to serve:
    [-p:54321, --port 54321]: Number for which port to listen for requests on
    [-z, --zero]: Use the any address 0.0.0.0 (instead of explicit localhost)
  How to yap:
    [-v, --verbose]: Extra information about the server as it runs will be logged
    [-l, --logfile]: Write logs to 'webdevn.log' within -d/--dir
    [-f, --forbidlogserve]: Returns 404 for requests of log file
  One-off Prints:
    [-V, --version]: Current build version
    [-h, --help]: This message
```

## Obtaining

### Building
This project is built using [nim](https://nim-lang.org/) + [nimble](https://nim-lang.github.io/nimble/) and [Task](https://taskfile.dev/). To compile the code yourself refer to the Task file for your platform.

For example to build for windows-64bit look at [`build/win/_tasks.yml`](build/win/_tasks.yml) and there (should) be a section/task called `rear-x64`; the contents of the `cmds` section will contain the steps for building. Variables common to all builds are defined in the toplevel [`Taskfile.yml`](Taskfile.yml) and also [`build/_tasks.yml`](build/_tasks.yml)
