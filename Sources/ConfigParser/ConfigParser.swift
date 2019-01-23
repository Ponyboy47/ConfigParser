import struct TrailBlazer.FilePath
import class TrailBlazer.Open
import typealias TrailBlazer.OpenFile
import struct Foundation.CharacterSet

public protocol ConfigParsable {
    mutating func nextCharacter(_ position: inout ConfigParser.ParserPosition) throws -> Character
}

public struct ConfigParser {
    public static let SectionStart = Character("[")
    public static let SectionEnd = Character("]")
    public static let CommentCharacters = Set([Character(";"), Character("#")])
    public static let KeyValueSeparator = Character("=")
    public static let Quotes = Set([Character("\""), Character("'")])
    public static let EscapeCharacter = Character("\\")

    public static let InvalidSectionCharacters = Set([ConfigParser.SectionStart, ConfigParser.KeyValueSeparator]).union(ConfigParser.CommentCharacters)
    public static let InvalidKeyValueCharacters = Set([ConfigParser.SectionStart, ConfigParser.SectionEnd, ConfigParser.KeyValueSeparator]).union(ConfigParser.CommentCharacters)
    public static let InvalidGlobalCharacters = Set([ConfigParser.SectionEnd, ConfigParser.KeyValueSeparator])

    public static var defaultEncoding: String.Encoding = .utf8

    public static func read(from configPath: FilePath, using encoding: String.Encoding = ConfigParser.defaultEncoding) throws -> Config {
        var openConfig = try configPath.open(permissions: .read)
        return try ConfigParser.parse(&openConfig)
    }

    public static func parse<ParseType: ConfigParsable>(_ parsable: inout ParseType) throws -> Config {
        let config = Config()
        var position = ParserPosition()

        var nextChar = try parsable.nextCharacter(&position)

        var currentSection: String = Config.GlobalKey
        var parsedSection = false

        repeat {
            // If we hit a newline, then skip it and get the next character
            if CharacterSet.newlines.contains(nextChar) {
                nextChar = try parsable.nextCharacter(&position)
                position.newline()
                parsedSection = false
            }
            
            if nextChar.isEmpty {
                break
            } else if nextChar == ConfigParser.SectionStart {
                currentSection = try ConfigParser.identifySectionTitle(&parsable, &position)
                if config[currentSection] == nil {
                    config[currentSection] = ConfigSection(title: currentSection)
                }

                parsedSection = true
            } else if ConfigParser.InvalidGlobalCharacters.contains(nextChar) {
                throw ParserError.invalidCharacter(nextChar, at: position)
            } else if ConfigParser.CommentCharacters.contains(nextChar) {
                try ConfigParser.skipToNextLine(&parsable, &position)
            } else if parsedSection && !CharacterSet.whitespaces.contains(nextChar) {
                throw ParserError.expectedNewlineOrEOF(at: position)
            } else {
                if config[currentSection] == nil {
                    config[currentSection] = ConfigSection(title: currentSection)
                }

                let key = try ConfigParser.parseKey(&parsable, &position)
                let value = try ConfigParser.parseValue(&parsable, &position)
                config[currentSection]![key] = value
            }

            if !CharacterSet.newlines.contains(nextChar) {
                nextChar = try parsable.nextCharacter(&position)
            }
        } while !nextChar.isEmpty

        return config
    }

    private static func identifySectionTitle<ParseType: ConfigParsable>(_ parsable: inout ParseType, _ position: inout ParserPosition) throws -> String {
        var sectionTitle = ""
        var nextChar = try parsable.nextCharacter(&position)

        while nextChar != ConfigParser.SectionEnd {
            guard !nextChar.isEmpty else {
                throw ParserError.unexpectedEOF(at: position)
            }
            guard !CharacterSet.newlines.contains(nextChar) else {
                throw ParserError.unexpectedNewline(at: position)
            }
            guard !CharacterSet.whitespaces.contains(nextChar) else {
                throw ParserError.unexpectedWhitespace(at: position)
            }
            guard !ConfigParser.InvalidSectionCharacters.contains(nextChar) else {
                throw ParserError.invalidCharacter(nextChar, at: position)
            }

            sectionTitle.append(nextChar)

            nextChar = try parsable.nextCharacter(&position)
        }

        guard sectionTitle.count > 0 else {
            throw ParserError.emptySectionTitle(at: position)
        }

        return sectionTitle
    }

    private static func parseKey<ParseType: ConfigParsable>(_ parsable: inout ParseType, _ position: inout ParserPosition) throws -> ConfigSection.Key {
        var key = ""
        var nextChar = try parsable.nextCharacter(&position)
        var hitWhitespace = false

        while nextChar != ConfigParser.KeyValueSeparator {
            guard !nextChar.isEmpty else {
                throw ParserError.unexpectedEOF(at: position)
            }
            guard !CharacterSet.newlines.contains(nextChar) else {
                throw ParserError.unexpectedNewline(at: position)
            }
            guard !ConfigParser.InvalidKeyValueCharacters.contains(nextChar) else {
                throw ParserError.invalidCharacter(nextChar, at: position)
            }

            if CharacterSet.whitespaces.contains(nextChar) {
                // This will trim leading whitespace, or cause an error to be
                // thrown if we encounter white space before the equals sign
                hitWhitespace = !key.isEmpty
            } else if hitWhitespace {
                throw ParserError.expectedEquals(at: position)
            } else {
                key.append(nextChar)
            }

            nextChar = try parsable.nextCharacter(&position)
        }

        guard key.count > 0 else {
            throw ParserError.emptyKey(at: position)
        }

        return key
    }

    private static func parseValue<ParseType: ConfigParsable>(_ parsable: inout ParseType, _ position: inout ParserPosition) throws -> ConfigSection.Value {
        var value = ""
        var nextChar = try parsable.nextCharacter(&position)
        var startingQuote: Character? = nil
        var escaped = false
        var closedQuote = false
        var whitespaces: [Character] = []

        while !nextChar.isEmpty && !CharacterSet.newlines.contains(nextChar) {
            guard !ConfigParser.InvalidKeyValueCharacters.contains(nextChar) else {
                throw ParserError.invalidCharacter(nextChar, at: position)
            }

            if closedQuote && !CharacterSet.whitespaces.contains(nextChar) {
                throw ParserError.unexpectedCharacterOutsideQuotedValue(at: position)
            } else if nextChar == ConfigParser.EscapeCharacter {
                escaped = true
            } else if value.isEmpty && !escaped && ConfigParser.Quotes.contains(nextChar) {
                startingQuote = nextChar
            } else if CharacterSet.whitespaces.contains(nextChar) {
                if !value.isEmpty {
                    whitespaces.append(nextChar)
                }
            } else if escaped || (!escaped && nextChar != startingQuote) {
                for char in whitespaces {
                    value.append(char)
                }
                value.append(nextChar)
                escaped = false
            } else if !escaped && nextChar == startingQuote {
                closedQuote = true
            } else {
                escaped = false
            }

            nextChar = try parsable.nextCharacter(&position)
        }

        guard value.count > 0 else {
            throw ParserError.emptyValue(at: position)
        }

        return value
    }

    private static func skipToNextLine<ParseType: ConfigParsable>(_ parsable: inout ParseType, _ position: inout ParserPosition) throws {
        var nextChar = try parsable.nextCharacter(&position)

        while !nextChar.isEmpty && !CharacterSet.newlines.contains(nextChar) {
            nextChar = try parsable.nextCharacter(&position)
        }
    }
}

extension ConfigParser {
    public struct ParserPosition: Equatable {
        public private(set) var line: Int = 1
        public private(set) var character: Int = 1

        fileprivate init() {}

        fileprivate mutating func step() {
            character += 1
        }

        fileprivate mutating func newline() {
            character = 1
            line += 1
        }
    }
}

extension Open: ConfigParsable where PathType == FilePath {
    private func readCharacter(using encoding: String.Encoding = .utf8) throws -> Character {
        // TODO: Need some way to identify bytes in the encoding
        guard let str = try read(bytes: 1, encoding: encoding) else {
            throw StringError.notConvertibleFromData(using: encoding)
        }

        return Character(str)
    }

    public func nextCharacter(_ position: inout ConfigParser.ParserPosition) throws -> Character {
        defer { position.step() }
        return try readCharacter(using: ConfigParser.defaultEncoding)
    }
}

extension String: ConfigParsable {
    public mutating func nextCharacter(_ position: inout ConfigParser.ParserPosition) -> Character {
        defer { position.step() }
        return isEmpty ? removeFirst() : Character("")
    }
}

fileprivate extension Character {
    fileprivate var isEmpty: Bool { return unicodeScalars.isEmpty }
}

fileprivate extension CharacterSet {
    fileprivate func contains(_ char: Character) -> Bool {
        for scalar in char.unicodeScalars {
            if contains(scalar) {
                return true
            }
        }
        return false
    }
}
