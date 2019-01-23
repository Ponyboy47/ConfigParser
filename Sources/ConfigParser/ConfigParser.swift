import struct TrailBlazer.FilePath
import class TrailBlazer.Open
import typealias TrailBlazer.OpenFile
import struct Foundation.CharacterSet

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
            while CharacterSet.newlines.contains(nextChar) {
                nextChar = try parsable.nextCharacter(&position)
                position.newline()
                parsedSection = false
            }
            
            if nextChar == .ETX {
                break
            } else if nextChar == ConfigParser.SectionStart {
                currentSection = try ConfigParser.identifySectionTitle(&nextChar, &parsable, &position)
                if config[currentSection] == nil {
                    config[currentSection] = ConfigSection(title: currentSection, parent: config)
                }

                parsedSection = true
            } else if ConfigParser.InvalidGlobalCharacters.contains(nextChar) {
                throw ParserError.invalidCharacter(nextChar, at: position)
            } else if ConfigParser.CommentCharacters.contains(nextChar) {
                try ConfigParser.skipToNextLine(&nextChar, &parsable, &position)
            } else if parsedSection && !CharacterSet.whitespaces.contains(nextChar) {
                throw ParserError.expectedNewlineOrEOF(at: position)
            } else if CharacterSet.whitespaces.contains(nextChar) {
                // Do nothing if we hit whitespace in the global scope
            } else {
                if config[currentSection] == nil {
                    config[currentSection] = ConfigSection(title: currentSection, parent: config)
                }

                let key = try ConfigParser.parseKey(&nextChar, &parsable, &position)
                let value = try ConfigParser.parseValue(&nextChar, &parsable, &position)
                config[currentSection]![key] = value
            }

            if !CharacterSet.newlines.contains(nextChar) {
                nextChar = try parsable.nextCharacter(&position)
            }
        } while nextChar != .ETX

        return config
    }

    private static func identifySectionTitle<ParseType: ConfigParsable>(_ nextChar: inout Character, _ parsable: inout ParseType, _ position: inout ParserPosition) throws -> String {
        var sectionTitle = ""
        nextChar = try parsable.nextCharacter(&position)

        while nextChar != ConfigParser.SectionEnd {
            guard nextChar != .ETX else {
                throw ParserError.unexpectedEOF(at: position)
            }
            guard !CharacterSet.newlines.contains(nextChar) else {
                throw ParserError.unexpectedNewline(at: position)
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

    private static func parseKey<ParseType: ConfigParsable>(_ nextChar: inout Character, _ parsable: inout ParseType, _ position: inout ParserPosition) throws -> ConfigSection.Key {
        var key = "\(nextChar)"
        nextChar = try parsable.nextCharacter(&position)
        var hitWhitespace = false

        while nextChar != ConfigParser.KeyValueSeparator {
            guard nextChar != .ETX else {
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

    private static func parseValue<ParseType: ConfigParsable>(_ nextChar: inout Character, _ parsable: inout ParseType, _ position: inout ParserPosition) throws -> ConfigSection.Value {
        nextChar = try parsable.nextCharacter(&position)
        var value = ""
        var startingQuote: Character? = nil
        var escaped = false
        var closedQuote = false
        var whitespaces: [Character] = []

        while nextChar != .ETX && !CharacterSet.newlines.contains(nextChar) {
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
                whitespaces = []
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

    private static func skipToNextLine<ParseType: ConfigParsable>(_ nextChar: inout Character, _ parsable: inout ParseType, _ position: inout ParserPosition) throws {
        nextChar = try parsable.nextCharacter(&position)

        while nextChar != .ETX && !CharacterSet.newlines.contains(nextChar) {
            nextChar = try parsable.nextCharacter(&position)
        }
    }
}

extension Character {
    static var ETX: Character { return Character(Unicode.Scalar(3)) }
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
