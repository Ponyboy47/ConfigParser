public enum StringError: Error {
    case notConvertibleFromData(using: String.Encoding)
}

public enum ParserError: Error {
    case unexpectedNewline(at: ParserPosition)
    case emptySectionTitle(at: ParserPosition)
    case emptyKey(at: ParserPosition)
    case emptyValue(at: ParserPosition)
    case invalidCharacter(Character, at: ParserPosition)
    case unexpectedEOF(at: ParserPosition)
    case expectedEquals(at: ParserPosition)
    case expectedNewlineOrEOF(at: ParserPosition)
    case unexpectedCharacterOutsideQuotedValue(at: ParserPosition)
}

public enum ConfigRetrievalError<T: ConfigRetrievable>: Error {
    case invalidValue(ConfigSection.Value, for: T.Type)
}
