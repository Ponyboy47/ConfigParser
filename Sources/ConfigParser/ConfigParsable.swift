import struct TrailBlazer.FilePath
import class TrailBlazer.Open

/// Types that can be parsed by the ConfigParser, character by character, to generate a Config
public protocol ConfigParsable {
    mutating func nextCharacter(options: ParserOptions) throws -> Character
}

extension Open: ConfigParsable where PathType == FilePath {
    private func readCharacter(using encoding: String.Encoding = .utf8) throws -> Character {
        // TODO: Need some way to identify bytes in the encoding
        guard let str = try read(bytes: 1, encoding: encoding) else {
            throw StringError.notConvertibleFromData(using: encoding)
        }

        // Characters cannot be initialized from an empty string. When we read
        // the EOF, the above statement should return an empty string. So when
        // we hit the EOF, return the ETX character to signify the end
        // of our parsable
        return str.isEmpty ? .ETX : Character(str)
    }

    /**
    Reads a single byte from the file and returns the associated character

    - Parameter position: The ParserPosition to where we have currently read in the file
    - Returns: Either the next character in the file, or the ETX character if the EOF has been reached
    - Warning: This will always throw if the file was encoded in such a way that characters are larger than one byte
    */
    public func nextCharacter(options: ParserOptions) throws -> Character {
        return try readCharacter(using: options.fileEncoding)
    }
}

extension String: ConfigParsable {
    /**
    Removes the first character of the string, until it is empty, at which
    point the ETX character is returned

    - Parameter position: The ParserPosition to where we have currently read in the string
    - Returns: Either the first character from the string or the ETX character
    */
    public mutating func nextCharacter(options: ParserOptions) -> Character {
        // Characters cannot be initialized from an empty string. When we have
        // finished processing the string, return the ETX character
        return isEmpty ? .ETX : removeFirst()
    }
}

