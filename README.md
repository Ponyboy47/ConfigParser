# ConfigParser

A pure-Swift implementation of the INI config parser

## Installation
### Swift Package Manager
```swift
.package(url: "https://github.com/Ponyboy47/ConfigParser.git", from: "0.4.0")
```

## Usage
```swift
import ConfigParser

let confString = """
[section1]
key1 = value1
key2 = 1, 2, 3, 4

[section2]
key1 = test
key2 = 1234
"""

let config = try ConfigParser.parse(confString)

// Use subscripts to get the value you want in the type you want
let key1s1: String? = config[section: "section1", key: "key1"] // Optional<String>(value1)
let key2s1 = config[section: "section2", key: "key1", default: [4, 3, 2, 1]] // [1, 2, 3, 4]
```
Supported Types:
- String
- Bool
- Int (8,16,32,64 and all the UInt variants)
- Double
- Float and Float80
- Arrays of any of the above types

## TODO
- [ ] Section/Key name validation (must start with an alphabet character)
- [x] Retrieve values as specified type
  - [x] Bool
  - [x] String (default)
  - [x] Double/Float
  - [x] Int
  - [x] Array
- [x] Write config to file
- [ ] Escape sequences (bug fix)
- [ ] Multi-line values
- [x] Read from string
- [ ] Customizable options
  - [ ] Delimeter (ie: ':' instead of '=')
  - [ ] Don't trim whitespace
  - [ ] Nested sections
    - [ ] Dotted section titles
    - [ ] Indented sections
  - [ ] Duplicate key behavior
    - [ ] Keep first
    - [ ] Overwrite
    - [ ] Error

## License
MIT
