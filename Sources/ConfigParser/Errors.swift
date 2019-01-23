public enum StringError: Error {
    case notConvertibleFromData(using: String.Encoding)
}

public enum ParserError: Error {
    case unexpectedNewline(at: ConfigParser.ParserPosition)
    case unexpectedWhitespace(at: ConfigParser.ParserPosition)
    case emptySectionTitle(at: ConfigParser.ParserPosition)
    case emptyKey(at: ConfigParser.ParserPosition)
    case emptyValue(at: ConfigParser.ParserPosition)
    case invalidCharacter(Character, at: ConfigParser.ParserPosition)
    case unexpectedEOF(at: ConfigParser.ParserPosition)
    case expectedEquals(at: ConfigParser.ParserPosition)
    case expectedNewlineOrEOF(at: ConfigParser.ParserPosition)
    case unexpectedCharacterOutsideQuotedValue(at: ConfigParser.ParserPosition)
}
