public struct ConfigSection: ExpressibleByDictionaryLiteral, Equatable, Hashable {
    public typealias Key = String
    public typealias Value = String

    public internal(set) var title: String = "unknown"
    var parent: Config!
    var _dict: [Key: Value]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(parent)
        hasher.combine(_dict)
    }

    public init(_ section: ConfigSection) {
        title = section.title
        _dict = section._dict
    }

    public init(title: String, data: [Key: Value] = [:]) {
        self.title = title
        _dict = data
    }

    public init(dictionaryLiteral elements: (Key, Value)...) {
        var _dict: [Key: Value] = [:]
        for (key, value) in elements {
            _dict[key] = value
        }
        self._dict = _dict
    }

    public func contains(_ key: Key) -> Bool {
        return _dict.keys.contains(key)
    }

    public subscript(key: Key) -> Value? {
        get {
            return _dict[key] ?? parent.get(default: key)
        }
        set { _dict[key] = newValue }
    }

    public static func == (lhs: ConfigSection, rhs: ConfigSection) -> Bool {
        return lhs._dict == rhs._dict
    }
}
