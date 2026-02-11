# (Web)(dev)(n)im
A web server for local development. Inspired by [webfs](https://linux.bytesex.org/misc/webfs.html).

* [Usage](#usage)
  - [Examples](#examples)
  - [Help Output](#help-output)
* [Obtaining](#obtaining)
  - [Building](#building)

## Usage
### Examples
serving the current folder
```
$ webdevn
```

serving a specific folder on a specific port
```
$ webdevn -d:./path/to/some/dir -p:54321
```

serving the current folder with an index file not named `index.html`
```
$ webdevn -i:custom_index.html
```

### Help Output
```
$ webdevn -h
webdevn - source lang: nim
package manager: nimble
binary version: 0.0.0

Usage:
  webdevn [OPTION]

OPTION[-SHORT:, --LONG]:
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

For short options like '-d:' be sure to include no space after the colon
```

## Obtaining
Pre-built binaries for supported platforms are available __only__ via [GitHub Releases](https://github.com/bharrisaplus/webdevn/releases). To verify a download:

__Linux/Mac__:

Make sure to install `shasum` if it's not already installed
```
# Verify the hash matches the "webdevn.zip.sha256"
$ shasum -a 256 "webdevn.zip"

$ unzip "webdevn.zip"

# Verify the hash matches the "webdevn.sha256"
$ shasum -a 256 "webdevn"
```
__Windows__:

`certutil` should come with the system
```
> certutil -hashfile "webdevn.zip" SHA256
:: Verify the hash matches the "webdevn.zip.sha256" then continue

> tar -xf "webdevn.zip"
:: Extract

> certutil -hashfile "webdevn.exe" SHA256
:: Verify the hash matches the webdevn.exe.sha256
```


### Building
To generate a binary be sure to have [nim](https://nim-lang.org/) installed. Then run the following to compile the code:
```
nim c -d:release --outDir:./ ./source/webdevn.nim
```
