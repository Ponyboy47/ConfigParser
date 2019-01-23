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

let config = try ConfigParser.read(from: "/path/to/config.ini")

let value = config["section"]?["key"]
```

## TODO
- [ ] Section/Key name validation (must start with an alphabet character)
- [ ] Retrieve values as specified type
  - [ ] Bool
  - [ ] String (default)
  - [ ] Double/Float
  - [ ] Int
  - [ ] Array
- [ ] Write config to file
- [ ] Escape sequences (bug fix)
- [ ] Multi-line values
- [ ] Read from string
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
