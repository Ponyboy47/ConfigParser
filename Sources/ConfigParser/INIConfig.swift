public protocol INIConfig: ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, Hashable 
                           where Key == String, Value == ConfigSection {
    /// The array element type
    typealias Element = Value

    /// The section key relating to global elements
    static var GlobalKey: Key { get }
    /// The section key relating to the default elements
    static var DefaultsKey: Key { get }

    /// Section containing the default values
    var defaults: Value { get set }
    /// Section containing the global values
    var globals: Value { get set }
    /// Underlying storage of the INIConfig
    var _dict: [Key: Value] { get set }

    /// Empty initializer
    init()
}

// Equatable & Hashable conformance
extension INIConfig {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(defaults)
        hasher.combine(globals)
        hasher.combine(_dict)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool { return lhs._dict == rhs._dict }
    public static func == <R: INIConfig>(lhs: Self, rhs: R) -> Bool { return lhs._dict == rhs._dict }
    public static func == <L: INIConfig>(lhs: L, rhs: Self) -> Bool { return lhs._dict == rhs._dict }
}

// ExpressibleByDictionaryLiteral conformance
extension INIConfig {
    /// Dictionary literal initializer
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()

        for (key, var value) in elements {
            value.title = key
            _dict[key] = value
        }
    }
}

// ExpressibleByArrayLiteral conformance
extension INIConfig {
    /// Array literal initializer
    public init(arrayLiteral elements: Element...) {
        self.init()

        for section in elements {
            _dict[section.title] = section
        }
    }
}

// Dict-like functionality
extension INIConfig {
    /// A view of the available sections in the INIConfig
    public var sections: Dictionary<Key, Value>.Keys { return _dict.keys }
    /// A view of the available sections in the INIConfig
    public var keys: Dictionary<Key, Value>.Keys { return sections }

    /**
    Determine if the config has values for the specified section

    - Parameter section: The section to search for in the config
    - Returns: Whether or not the section exists in the config
    */
    public func contains(section key: Key) -> Bool { return keys.contains(key) }

    public func section(withKey key: ConfigSection.Key) -> ConfigSection? {
        if key == Self.GlobalKey {
            return globals
        } else if key == Self.DefaultsKey {
            return defaults
        }
        return _dict[key]
    }
    public subscript(_ section: Key) -> ConfigSection? {
        get { return self.section(withKey: section) }
        set {
            if section == Self.GlobalKey {
                globals = newValue ?? [:]
            } else if section == Self.DefaultsKey {
                defaults = newValue ?? [:]
            }
            _dict[section] = newValue
        }
    }

    public func get(default key: ConfigSection.Key) -> ConfigSection.Value? { return defaults[key] }
    public func get(global key: ConfigSection.Key) -> ConfigSection.Value? { return globals[key] }
    public subscript(section key: Key, key item: ConfigSection.Key) -> ConfigSection.Value? {
        get { return _dict[key]?[item] ?? globals[item] ?? defaults[item] }
        set { _dict[key]?[item] = newValue }
    }
    public subscript(section key: Key, key item: ConfigSection.Key, default: ConfigSection.Value) -> ConfigSection.Value {
        return self[section: key, key: item] ?? `default`
    }
}
