import struct TrailBlazer.FileMode
import struct TrailBlazer.FilePath

public protocol INIConfig: ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, Hashable
    where Key == String, Value == ConfigSection {
    /// The array element type
    typealias Element = Value

    /// The section key relating to global elements
    static var GlobalsKey: Key { get }
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

public extension INIConfig {
    // MARK: Equatable & Hashable conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(defaults)
        hasher.combine(globals)
        hasher.combine(_dict)
    }

    static func == (lhs: Self, rhs: Self) -> Bool { return lhs._dict == rhs._dict }
    static func == <R: INIConfig>(lhs: Self, rhs: R) -> Bool { return lhs._dict == rhs._dict }
    static func == <L: INIConfig>(lhs: L, rhs: Self) -> Bool { return lhs._dict == rhs._dict }

    // MARK: ExpressibleByDictionaryLiteral conformance

    /// Dictionary literal initializer
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()

        for (key, var value) in elements {
            value.title = key
            _dict[key] = value
        }
    }

    // MARK: ExpressibleByArrayLiteral conformance

    /// Array literal initializer
    init(arrayLiteral elements: Element...) {
        self.init()

        for section in elements {
            _dict[section.title] = section
        }
    }

    // MARK: Dict-like functionality

    /// A view of the available sections in the INIConfig
    var sections: Dictionary<Key, Value>.Keys { return _dict.keys }
    /// A view of the available sections in the INIConfig
    var keys: Dictionary<Key, Value>.Keys { return sections }

    /**
     Determine if the config has values for the specified section

     - Parameter section: The section to search for in the config
     - Returns: Whether or not the section exists in the config
     */
    func contains(section key: Key) -> Bool { return keys.contains(key) }

    func section(withKey key: ConfigSection.Key) -> ConfigSection? {
        if key == Self.GlobalsKey {
            return globals
        } else if key == Self.DefaultsKey {
            return defaults
        }
        return _dict[key]
    }

    func get(default key: ConfigSection.Key) -> ConfigSection.Value? { return defaults[key] }
    func get(global key: ConfigSection.Key) -> ConfigSection.Value? { return globals[key] }
    subscript(section key: Key, key item: ConfigSection.Key, default default: ConfigSection.Value) -> ConfigSection.Value {
        return self[section: key, key: item] ?? `default`
    }

    subscript<T: ConfigRetrievable>(section key: Key, key item: ConfigSection.Key) -> T? {
        guard let value = self[section: key, key: item] else { return nil }
        return T.from(value: value)
    }

    subscript<T: ConfigRetrievable>(section key: Key, key item: ConfigSection.Key, default default: T) -> T {
        guard let value = self[section: key, key: item] else { return `default` }
        return T.from(value: value) ?? `default`
    }

    subscript(_ section: Key) -> ConfigSection? {
        return self.section(withKey: section)
    }

    subscript(section key: Key, key item: ConfigSection.Key) -> ConfigSection.Value? {
        return _dict[key]?[item] ?? globals[item] ?? defaults[item]
    }

    // MARK: Useful file operations

    init(from configPath: FilePath, options: ParserOptions = .default) throws {
        self = try ConfigParser.read(from: configPath, options: options)
    }

    func output(options _: ParserOptions = .default) -> String {
        var config = String()

        for (key, value) in globals._dict {
            config += key
            config += " = "
            config += value
            config += "\n"
        }

        if !defaults.isEmpty {
            if !globals.isEmpty {
                config += "\n"
            }

            config.append(ConfigParser.SectionStart)
            config += Self.DefaultsKey
            config.append(ConfigParser.SectionEnd)
            config += "\n"

            for (key, value) in defaults._dict {
                config += key
                config += " = "
                config += value
                config += "\n"
            }
        }

        if !_dict.isEmpty, !defaults.isEmpty || !globals.isEmpty {
            config += "\n"
        }

        var index = _dict.startIndex
        while index != _dict.endIndex {
            let (sectionTitle, section) = _dict[index]

            config.append(ConfigParser.SectionStart)
            config += sectionTitle
            config.append(ConfigParser.SectionEnd)
            config += "\n"

            for (key, value) in section._dict {
                config += key
                config += " = "
                config += value
                config += "\n"
            }

            index = _dict.index(after: index)
            if index != _dict.endIndex {
                config += "\n"
            }
        }

        return config
    }

    func save(to path: FilePath, options: ParserOptions = .default, mode: FileMode = .init(owner: .all, group: .readWrite, others: .read)) throws {
        try (path.absolute ?? path).open(mode: "w+") { opened in
            try opened.write(output(options: options))
            try opened.change(permissions: mode)
        }
    }
}
