/// Options that change the behavior of the ConfigParser
public struct ParserOptions {
    /// The default characters recognized as comment openers
    public static let defaultCommentCharacters = Set([Character(";"), Character("#")])
    /// The default separator between a key and a value
    public static let defaultKeyValueSeparator = Character("=")

    /// The characters recognized as comment beginnings
    public var commentCharacters: Set<Character>
    /// The character used to separate between a key and a value
    public var keyValueSeparator: Character

    public static let `default` = ParserOptions()

    public init(commentCharacters: Set<Character> = ParserOptions.defaultCommentCharacters,
                keyValueSeparator: Character = ParserOptions.defaultKeyValueSeparator) {
        self.commentCharacters = commentCharacters
        self.keyValueSeparator = keyValueSeparator
    }
}
