public final class Config: ExpressibleByDictionaryLiteral, Equatable, Hashable {
    public typealias Key = String
    public typealias Value = ConfigSection

    public static let GlobalKey = "GLOBALS"
    public static let DefaultsKey = "DEFAULTS"

    public var defaults: ConfigSection = [:]
    public var globals: ConfigSection = [:]
    var _dict: [Key: Value] = [:]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(defaults)
        hasher.combine(globals)
        hasher.combine(_dict)
    }

    public init() {}

    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, var value) in elements {
            value.title = key
            value.parent = self
            _dict[key] = value
        }
    }

    public func sections() -> Dictionary<Config.Key, Config.Value>.Keys {
        return _dict.keys
    }

    public func contains(section: Config.Key) -> Bool {
        return _dict.keys.contains(section)
    }

    func get(default key: ConfigSection.Key) -> ConfigSection.Value? {
        return defaults[key]
    }

    func get(section: Key, key: ConfigSection.Key, default: ConfigSection.Value? = nil) -> ConfigSection.Value? {
        return self[section, key] ?? `default`
    }

    public subscript(section: Key, key: ConfigSection.Key) -> ConfigSection.Value? {
        return self[section]?[key] ?? get(default: key)
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
            } else {
                _dict[section] = newValue
            }
        }
    }

    public static func == (lhs: Config, rhs: Config) -> Bool {
        return lhs._dict == rhs._dict
    }
}
