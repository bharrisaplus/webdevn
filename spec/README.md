# Testing

## Overview

_Behavior_ and _Shape_ are the simplest type of checks
  * __Shape__ is where you want to make sure it 'looks' right
  * __Behaviors__ make sure the code 'responds' correctly to both good and bad input


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
