/// A single section of a Config
public struct ConfigSection: ExpressibleByDictionaryLiteral, Equatable, Hashable {
    public typealias Key = String
    public typealias Value = String

    /// The title of the section
    public internal(set) var title: String!
    /// The underlying storage of the section
    var _dict: [Key: Value]

    public var isEmpty: Bool { return _dict.isEmpty }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(_dict)
    }

    /// Copy this ConfigSection from another
    public init(_ section: ConfigSection) {
        title = section.title
        _dict = section._dict
    }

    /// Initializer
    public init(title: String, data: [Key: Value] = [:]) {
        self.title = title
        _dict = data
    }

    /// Initialize from a dictionary literal expression
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var _dict: [Key: Value] = [:]
        for (key, value) in elements {
            _dict[key] = value
        }
        self._dict = _dict
    }

    /**
    Check if the section contains a value for the specified key

    - Parameter key: The key to search for in the section
    - Returns: Whether or not the key is contained in the section
    */
    public func contains(_ key: Key) -> Bool {
        return _dict.keys.contains(key)
    }

    /// Returns a value for the specified key or nil if it doesn't exist
    public subscript(key: Key) -> [Value]? {
        get { return _dict[key]?.components(separatedBy: ",").map({ return $0.trimmingCharacters(in: .whitespaces) }) }
        mutating set { _dict[key] = newValue?.joined(separator: ",") }
    }

    /// Returns a value for the specified key or nil if it doesn't exist
    public subscript(key: Key) -> Value? {
        get { return _dict[key] }
        mutating set { _dict[key] = newValue }
    }

    public subscript<T: ConfigRetrievable>(key: Key, default: T) -> T {
        guard let value = _dict[key] else { return `default` }
        return T.from(value: value) ?? `default`
    }

    public subscript<T: ConfigStorable>(key: Key) -> T? {
        get {
            guard let value = _dict[key] else { return nil }
            return T.from(value: value)
        }
        mutating set {
            self[key] = newValue?.toValue()
        }
    }

    public func get<T: ConfigRetrievable>(key: Key) -> T? {
        guard let value = _dict[key] else { return nil }
        return T.from(value: value)
    }

    public func get<T: ConfigRetrievable>(key: Key, default: T) -> T {
        guard let value = _dict[key] else { return `default` }
        return T.from(value: value) ?? `default`
    }

    public mutating func set<T: ConfigStorable>(key: Key, value newValue: T?) {
        _dict[key] = newValue?.toValue()
    }

    public static func == (lhs: ConfigSection, rhs: ConfigSection) -> Bool {
        return lhs._dict == rhs._dict
    }
}
