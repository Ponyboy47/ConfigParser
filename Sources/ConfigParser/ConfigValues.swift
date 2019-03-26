public protocol ConfigRetrievable {
    static func from(value: ConfigSection.Value) -> Self?
}

public protocol ConfigStorable: ConfigRetrievable {
    func toValue() -> ConfigSection.Value
}

extension String: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> String? { return value }

    public func toValue() -> ConfigSection.Value { return self }
}

extension Bool: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Bool? {
        switch value {
        case "true", "1", "on", "yes": return true
        case "false", "0", "off", "no": return false
        default: return nil
        }
    }

    public func toValue() -> ConfigSection.Value { return self ? "true" : "false" }
}

public extension Numeric {
    func toValue() -> ConfigSection.Value { return "\(self)" }
}

extension Int8: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Int8? {
        return Int8(value)
    }
}

extension Int16: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Int16? {
        return Int16(value)
    }
}

extension Int32: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Int32? {
        return Int32(value)
    }
}

extension Int64: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Int64? {
        return Int64(value)
    }
}

extension Int: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Int? {
        return Int(value)
    }
}

extension UInt8: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> UInt8? {
        return UInt8(value)
    }
}

extension UInt16: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> UInt16? {
        return UInt16(value)
    }
}

extension UInt32: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> UInt32? {
        return UInt32(value)
    }
}

extension UInt64: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> UInt64? {
        return UInt64(value)
    }
}

extension UInt: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> UInt? {
        return UInt(value)
    }
}

extension Double: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Double? {
        return Double(value)
    }
}

extension Float: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Float? {
        return Float(value)
    }
}

extension Float80: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> Float80? {
        return Float80(value)
    }
}

extension Array: ConfigRetrievable where Element: ConfigRetrievable {
    public static func from(value: ConfigSection.Value) -> [Element]? {
        var items = Array<Element>()
        for item in value.components(separatedBy: ",") {
            guard let val = Element.from(value: item.trimmingCharacters(in: .whitespaces)) else { return nil }
            items.append(val)
        }
        return items
    }
}

extension Array: ConfigStorable where Element: ConfigStorable {
    public func toValue() -> ConfigSection.Value {
        return map({ $0.toValue() }).joined(separator: ", ")
    }
}
