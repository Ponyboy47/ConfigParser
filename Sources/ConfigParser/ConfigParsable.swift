import struct TrailBlazer.FilePath
import class TrailBlazer.Open

public protocol ConfigParsable {
    mutating func nextCharacter(_ position: inout ParserPosition) throws -> Character
}

extension Open: ConfigParsable where PathType == FilePath {
    private func readCharacter(using encoding: String.Encoding = .utf8) throws -> Character {
        // TODO: Need some way to identify bytes in the encoding
        guard let str = try read(bytes: 1, encoding: encoding) else {
            throw StringError.notConvertibleFromData(using: encoding)
        }

        return str.isEmpty ? .ETX : Character(str)
    }

    public func nextCharacter(_ position: inout ParserPosition) throws -> Character {
        defer { position.step() }
        return try readCharacter(using: ConfigParser.defaultEncoding)
    }
}

extension String: ConfigParsable {
    public mutating func nextCharacter(_ position: inout ParserPosition) -> Character {
        defer { position.step() }
        return isEmpty ? .ETX : removeFirst()
    }
}

