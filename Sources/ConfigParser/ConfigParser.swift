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
    /// The quotation characters
    private static let Quotes = Set([Character("\""), Character("'")])
    /// The escape character
    private static let EscapeCharacter = Character("\\")

    /// Characters not permitted as part of a section title
    private lazy var invalidSectionCharacters = {
        Set([ConfigParser.SectionStart, options.keyValueSeparator]).union(options.commentCharacters)
    }()
    /// Character not permitted in either a key or a value
    private lazy var invalidKeyValueCharacters = {
        Set([ConfigParser.SectionStart, ConfigParser.SectionEnd, options.keyValueSeparator]).union(options.commentCharacters)
    }()
    /// Characters not permitted in the global scope
    private lazy var invalidGlobalCharacters = {
        Set([ConfigParser.SectionEnd, options.keyValueSeparator])
    }()

    private var parsable: ConfigParsable
    private var nextChar: Character!
    private var options: ParserOptions
    private var position = ParserPosition()

    private init<ParseType: ConfigParsable>(_ parsable: ParseType, options: ParserOptions) throws {
        self.parsable = parsable
        self.options = options
        self.nextChar = try self.parsable.nextCharacter(options: self.options)
    }

    private mutating func nextCharacter(newline: Bool = false) throws {
        defer { newline ? position.newline() : position.step() }
        nextChar = try parsable.nextCharacter(options: self.options)
    }

    /**
    Reads a config from the specified file path

    - Parameter configPath: The FilePath to the config
    - Parameter encoding: The encoding to use when reading the file
    - Returns: A Config after reading the FilePath
    */
    public static func read(from configPath: FilePath, options: ParserOptions = .default) throws -> Config {
        // Expand the path (in case it's relative) and then open it for reading
        var openConfig = try configPath.expanded().open(permissions: .read)

        // Pass the readable config to the parser
        return try ConfigParser.parse(&openConfig, options: options)
    }

    /**
    Parses the Parsable object, character by character, until it has generated an entire Config

    - Parameter parsable: A type conforming to ConfigParsable which can be read character by character
    - Returns: A Config object
    */
    public static func parse<ParseType: ConfigParsable>(_ parsable: inout ParseType, options: ParserOptions = .default) throws -> Config {
        // Create our empty Config
        let config = Config()
        var parser = try ConfigParser(parsable, options: options)

        // Until we hit our first section, we're a part of the global section
        var currentSection: String = Config.GlobalKey
        // Track when we've parsed a section title so we can throw if we
        // encounter an invalid character outside the section markers
        var parsedSection = false

        // Keep reading characters until we've hit the End of Text marker
        while parser.nextChar != .ETX {
            // If we hit a newline, then skip it and get the next character
            while CharacterSet.newlines.contains(parser.nextChar) {
                try parser.nextCharacter(newline: true)
                parsedSection = false
            }

            // We could encounter the ETX char after skipping newlines above
            if parser.nextChar == .ETX {
                break
            } else if parser.nextChar == ConfigParser.SectionStart {
                currentSection = try parser.identifySectionTitle()
                if config[currentSection] == nil {
                    config[currentSection] = ConfigSection(title: currentSection)
                }

                parsedSection = true
            } else if parser.invalidGlobalCharacters.contains(parser.nextChar) {
                throw ParserError.invalidCharacter(parser.nextChar, at: parser.position)
            } else if options.commentCharacters.contains(parser.nextChar) {
                try parser.skipToNextLine()
            } else if parsedSection && !CharacterSet.whitespaces.contains(parser.nextChar) {
                throw ParserError.expectedNewlineOrEOF(at: parser.position)
            } else if CharacterSet.whitespaces.contains(parser.nextChar) {
                // Do nothing if we hit whitespace in the global scope
            } else {
                let key = try parser.parseKey()
                let value = try parser.parseValue()
                config[currentSection]![key] = value
            }

            if !CharacterSet.newlines.contains(parser.nextChar) {
                try parser.nextCharacter()
            }
        }

        return config
    }

    /// Reads a section title encapsulated by []
    private mutating func identifySectionTitle() throws -> String {
        var sectionTitle = ""
        try nextCharacter()

        while nextChar != ConfigParser.SectionEnd {
            guard nextChar != .ETX else {
                throw ParserError.unexpectedEOF(at: position)
            }
            guard !CharacterSet.newlines.contains(nextChar) else {
                throw ParserError.unexpectedNewline(at: position)
            }
            guard !invalidSectionCharacters.contains(nextChar) else {
                throw ParserError.invalidCharacter(nextChar, at: position)
            }

            sectionTitle.append(nextChar)

            try nextCharacter()
        }

        guard sectionTitle.count > 0 else {
            throw ParserError.emptySectionTitle(at: position)
        }

        return sectionTitle
    }

    /// Reads a key up to the separator '=' by default
    private mutating func parseKey() throws -> ConfigSection.Key {
        var key = "\(nextChar!)"
        try nextCharacter()
        var hitWhitespace = false

        while nextChar != options.keyValueSeparator {
            guard nextChar != .ETX else {
                throw ParserError.unexpectedEOF(at: position)
            }
            guard !CharacterSet.newlines.contains(nextChar) else {
                throw ParserError.unexpectedNewline(at: position)
            }
            guard !invalidKeyValueCharacters.contains(nextChar) else {
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

            try nextCharacter()
        }

        guard key.count > 0 else {
            throw ParserError.emptyKey(at: position)
        }

        return key
    }

    /// Reads a value, up to a newline or EOF/ETX
    private mutating func parseValue() throws -> ConfigSection.Value {
        try nextCharacter()
        var value = ""
        var startingQuote: Character? = nil
        var escaped = false
        var closedQuote = false
        var whitespaces: [Character] = []

        while nextChar != .ETX && !CharacterSet.newlines.contains(nextChar) {
            guard !invalidKeyValueCharacters.contains(nextChar) else {
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

            try nextCharacter()
        }

        guard value.count > 0 else {
            throw ParserError.emptyValue(at: position)
        }

        return value
    }

    /// Used when parsing lines containing comments. Skips all characters up through the end of the line/file/string
    private mutating func skipToNextLine() throws {
        try nextCharacter()

        while nextChar != .ETX && !CharacterSet.newlines.contains(nextChar) {
            try nextCharacter()
        }
    }
}

extension Character {
    /// The End of Text Character
    public static var ETX: Character { return Character(Unicode.Scalar(3)) }
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
