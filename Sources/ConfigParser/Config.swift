public final class Config: ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, Equatable, Hashable {
    public typealias Key = String
    public typealias Value = ConfigSection
    public typealias Element = Value

    /// The section key relating to global elements
    public static let GlobalKey = "GLOBALS"
    /// The section key relating to the default elements
    public static let DefaultsKey = "DEFAULTS"

    /// Section containing the default values
    public var defaults: ConfigSection = [:]
    /// Section containing the global values
    public var globals: ConfigSection = [:]
    /// Underlying storage of the Config
    var _dict: [Key: Value] = [:]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(defaults)
        hasher.combine(globals)
        hasher.combine(_dict)
    }

    /// Empty initializer
    public init() {}

    /// Dictionary literal initializer
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, var value) in elements {
            value.title = key
            _dict[key] = value
        }
    }

    /// Array literal initializer
    public init(arrayLiteral elements: Element...) {
        for section in elements {
            _dict[section.title] = section
        }
    }

    /// A View of the available sections in the Config
    public func sections() -> Dictionary<Config.Key, Config.Value>.Keys {
        return _dict.keys
    }

    /**
    Determine if the config has values for the specified section

    - Parameter section: The section to search for in the config
    - Returns: Whether or not the section exists in the config
    */
    public func contains(section: Config.Key) -> Bool {
        return _dict.keys.contains(section)
    }

    public func get(default key: ConfigSection.Key) -> ConfigSection.Value? {
        return defaults[key]
    }

    public func get(global key: ConfigSection.Key) -> ConfigSection.Value? {
        return globals[key]
    }

    public subscript(section: Key) -> ConfigSection? {
        get {
            if section == Config.GlobalKey {
                return globals
            } else if section == Config.DefaultsKey {
                return defaults
            }
            return _dict[section]
        }
        set {
            if section == Config.GlobalKey {
                globals = newValue ?? [:]
            } else if section == Config.DefaultsKey {
                defaults = newValue ?? [:]
            }
            _dict[section] = newValue
        }
    }

    public subscript(section: Key, key: ConfigSection.Key) -> ConfigSection.Value? {
        get { return self[section]?[key] ?? defaults[key] }
        set { self[section]?[key] = newValue }
    }

    public subscript(section: Key, key: ConfigSection.Key, default: ConfigSection.Value) -> ConfigSection.Value? {
        return self[section]?[key] ?? defaults[key] ?? `default`
    }

    public static func == (lhs: Config, rhs: Config) -> Bool {
        return lhs._dict == rhs._dict
    }
}
