# ConfigParser

A pure-Swift implementation of the INI config parser

## Installation
### Swift Package Manager
```swift
.package(url: "https://github.com/Ponyboy47/ConfigParser.git", from: "0.1.0")
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

// Subscripting will always return a String value
let key1: String? = config["section1"]?["key1"] // value1
let key1 = config["section2"]?["key1"] // test
let key2 = config["section1"]?["key2"] // nil

// You can automatically cast to others like so:
let key2: Int = try config["section2"]?.get(key: "key2") // 1234
// or
let key2 = try config["section2"]?.getInt(key: "key2") // 1234

// You can retrieve arrays like so:
let array: [Int] = try config["section1"]?.get(key: "key2") // [1, 2, 3, 4]
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
- [ ] Write config to file
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
