/// Options that change the behavior of the ConfigParser
public struct ParserOptions {
    /// The default characters recognized as comment openers
    public static let defaultCommentCharacters = Set([Character(";"), Character("#")])
    /// The default separator between a key and a value
    public static let defaultKeyValueSeparator = Character("=")
    /// The default encoding used when reading from a file
    public static let defaultFileEncoding: String.Encoding = .utf8

    /// The characters recognized as comment beginnings
    public var commentCharacters: Set<Character>
    /// The character used to separate between a key and a value
    public var keyValueSeparator: Character
    /// The encoding used to read from a file
    public var fileEncoding: String.Encoding

    public static let `default` = ParserOptions()

    public init(commentCharacters: Set<Character> = ParserOptions.defaultCommentCharacters,
                keyValueSeparator: Character = ParserOptions.defaultKeyValueSeparator,
                fileEncoding: String.Encoding = ParserOptions.defaultFileEncoding) {
        self.commentCharacters = commentCharacters
        self.keyValueSeparator = keyValueSeparator
        self.fileEncoding = fileEncoding
    }
}
