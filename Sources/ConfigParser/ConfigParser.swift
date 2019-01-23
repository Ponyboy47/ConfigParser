import struct TrailBlazer.FilePath
import class TrailBlazer.Open
import typealias TrailBlazer.OpenFile
import struct Foundation.CharacterSet

/// A type used to parse a string or file into a Config object
public struct ConfigParser {
    /// The start of an INI section title
    public static let SectionStart = Character("[")
    /// The end of an INI section title
    public static let SectionEnd = Character("]")
    /// The characters permitted to be used when beginning a comment
    public static let CommentCharacters = Set([Character(";"), Character("#")])
    /// The separator between a key and its value
    public static let KeyValueSeparator = Character("=")
    /// The quotation characters
    private static let Quotes = Set([Character("\""), Character("'")])
    /// The escape character
    public static let EscapeCharacter = Character("\\")

    /// Characters not permitted as part of a section title
    public static let InvalidSectionCharacters = Set([ConfigParser.SectionStart, ConfigParser.KeyValueSeparator]).union(ConfigParser.CommentCharacters)
    /// Character not permitted in either a key or a value
    public static let InvalidKeyValueCharacters = Set([ConfigParser.SectionStart, ConfigParser.SectionEnd, ConfigParser.KeyValueSeparator]).union(ConfigParser.CommentCharacters)
    /// Characters not permitted in the global scope
    public static let InvalidGlobalCharacters = Set([ConfigParser.SectionEnd, ConfigParser.KeyValueSeparator])

    /// The default encoding to use when reading from a file
    public static var defaultEncoding: String.Encoding = .utf8

    /**
    Reads a config from the specified file path

    - Parameter configPath: The FilePath to the config
    - Parameter encoding: The encoding to use when reading the file
    - Returns: A Config after reading the FilePath
    */
    public static func read(from configPath: FilePath, using encoding: String.Encoding = ConfigParser.defaultEncoding) throws -> Config {
        // Expand the path (in case it's relative) and then open it for reading
        var openConfig = try configPath.expanded().open(permissions: .read)

        // Pass the readable config to the parser
        return try ConfigParser.parse(&openConfig)
    }

    /**
    Parses the Parsable object, character by character, until it has generated an entire Config

    - Parameter parsable: A type conforming to ConfigParsable which can be read character by character
    - Returns: A Config object
    */
    public static func parse<ParseType: ConfigParsable>(_ parsable: inout ParseType) throws -> Config {
        // Create our empty Config
        let config = Config()

        // Start tracking our position and grab the first character
        var position = ParserPosition()
        var nextChar = try parsable.nextCharacter(&position)

        // Until we hit our first section, we're a part of the global section
        var currentSection: String = Config.GlobalKey
        // Track when we've parsed a section title so we can throw if we
        // encounter an invalid character outside the section markers
        var parsedSection = false

        // Keep reading characters until we've hit the End of Text marker
        while nextChar != .ETX {
            // If we hit a newline, then skip it and get the next character
            while CharacterSet.newlines.contains(nextChar) {
                nextChar = try parsable.nextCharacter(&position)
                position.newline()
                parsedSection = false
            }
            
            // We could encounter the ETX char after skipping newlines above
            if nextChar == .ETX {
                break
            } else if nextChar == ConfigParser.SectionStart {
                currentSection = try ConfigParser.identifySectionTitle(&nextChar, &parsable, &position)
                if config[currentSection] == nil {
                    config[currentSection] = ConfigSection(title: currentSection)
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
                let key = try ConfigParser.parseKey(&nextChar, &parsable, &position)
                let value = try ConfigParser.parseValue(&nextChar, &parsable, &position)
                config[currentSection]![key] = value
            }

            if !CharacterSet.newlines.contains(nextChar) {
                nextChar = try parsable.nextCharacter(&position)
            }
        }

        return config
    }

    /// Reads a section title encapsulated by []
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

    /// Reads a key up to the separator '=' by default
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

    /// Reads a value, up to a newline or EOF/ETX
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

    /// Used when parsing lines containing comments. Skips all characters up through the end of the line/file/string
    private static func skipToNextLine<ParseType: ConfigParsable>(_ nextChar: inout Character, _ parsable: inout ParseType, _ position: inout ParserPosition) throws {
        nextChar = try parsable.nextCharacter(&position)

        while nextChar != .ETX && !CharacterSet.newlines.contains(nextChar) {
            nextChar = try parsable.nextCharacter(&position)
        }
    }
}

extension Character {
    /// The End of Text Character
    static var ETX: Character { return Character(Unicode.Scalar(3)) }
}

fileprivate extension CharacterSet {
    /// Checks if the CharacterSet contains the specified Character
    fileprivate func contains(_ char: Character) -> Bool {
        for scalar in char.unicodeScalars {
            if contains(scalar) {
                return true
            }
        }
        return false
    }
}
