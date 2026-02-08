# Testing

## Overview

_Behavior_ and _Shape_ are checks that encompass unit and integration test methodologies.
  * __Shape__ is where you want to make sure output looks right
  * __Behavior__ make sure the code responds correctly to both good and bad input

(documentation on the fuzz and/or stress testing and any security audits go below)

Directory structure:
```
spec/
├── appa <-- Apparatus; Files to use for testing/debugging
│   ├── example_safesearch <-- A file the exists in the parent directory
│   │
│   ├── example_safesearchnode <-- A file that exists in teh parent parent directory
│   │
│   ├── has_index <-- index.html
│   │
│   ├── has_index_custom <-- custom.html
│   │
│   └── has_no_index <-- Empty directory
│
└── bs <-- Behavior and Shape tests/suites
```

## Auditing
Since nim compiles to C the contents of the nimcache folder could possible be scanned for vulnerabilities to make use of popular audit tools like snyk/qube/vera/etc that support C.
