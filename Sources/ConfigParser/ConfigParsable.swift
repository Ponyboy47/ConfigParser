import struct TrailBlazer.FilePath
import class TrailBlazer.Open

/// Types that can be parsed by the ConfigParser, character by character, to generate a Config
public protocol ConfigParsable {
    mutating func nextCharacter() throws -> Character
}

extension Open: ConfigParsable where PathType == FilePath {}

extension String: ConfigParsable {
    /**
     Removes the first character of the string, until it is empty, at which
     point the ETX character is returned

     - Parameter position: The ParserPosition to where we have currently read in the string
     - Returns: Either the first character from the string or the ETX character
     */
    public mutating func nextCharacter() -> Character {
        // Characters cannot be initialized from an empty string. When we have
        // finished processing the string, return the ETX character
        return isEmpty ? .ETX : removeFirst()
    }
}
