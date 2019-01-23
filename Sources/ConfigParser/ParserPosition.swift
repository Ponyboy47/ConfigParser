public struct ParserPosition: Equatable, CustomStringConvertible {
    public private(set) var line: Int = 1
    public private(set) var character: Int = 1

    public var description: String {
        return "ParserPosition(line: \(line), character: \(character))"
    }

    init() {}

    mutating func step() {
        character += 1
    }

    mutating func newline() {
        character = 1
        line += 1
    }
}
