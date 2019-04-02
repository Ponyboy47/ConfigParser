open class Config: INIConfig {
    /// The section key relating to global elements
    public static let GlobalsKey = "GLOBALS"
    /// The section key relating to the default elements
    public static let DefaultsKey = "DEFAULTS"

    /// Section containing the default values
    public var defaults: ConfigSection = [:]
    /// Section containing the global values
    public var globals: ConfigSection = [:]
    /// Underlying storage of the Config
    public var _dict: [Key: Value] = [:]

    public var keys: Dictionary<Key, Value>.Keys { return _dict.keys }
    public var sections: Dictionary<Key, Value>.Keys { return keys }
    public var values: Dictionary<Key, Value>.Values { return _dict.values }

    /// Empty initializer
    public required init() {}

    public subscript(_ section: Key) -> ConfigSection? {
        get { return self.section(withKey: section) }
        set {
            if section == Config.GlobalsKey {
                globals = newValue ?? [:]
            } else if section == Config.DefaultsKey {
                defaults = newValue ?? [:]
            } else {
                _dict[section] = newValue
            }
        }
    }

    public subscript(section key: Key, key item: ConfigSection.Key) -> ConfigSection.Value? {
        get { return _dict[key]?[item] ?? globals[item] ?? defaults[item] }
        set {
            if key == Config.GlobalsKey {
                globals[item] = newValue
            } else if key == Config.DefaultsKey {
                defaults[item] = newValue
            } else {
                if !_dict.keys.contains(key) {
                    _dict[key] = ConfigSection(title: key)
                }
                _dict[key]![item] = newValue
            }
        }
    }

    public subscript<T: ConfigStorable>(section key: Key, key item: ConfigSection.Key) -> T? {
        get {
            guard let value: ConfigSection.Value = self[section: key, key: item] else { return nil }
            return T.from(value: value)
        }
        set {
            self[section: key, key: item] = newValue?.toValue()
        }
    }
}
