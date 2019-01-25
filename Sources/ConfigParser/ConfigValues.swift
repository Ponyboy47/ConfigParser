public protocol ConfigRetrievable {
    static func from(value: ConfigSection.Value) throws -> Self
}

public protocol ConfigStorable: ConfigRetrievable {
    func toValue() -> ConfigSection.Value
}

extension String: ConfigStorable {
    public static func from(value: ConfigSection.Value) -> String { return value }

    public func toValue() -> ConfigSection.Value { return self }
}

extension Bool: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Bool {
        switch value {
        case "true", "1", "on", "yes": return true
        case "false", "0", "off", "no": return false
        default: throw ConfigRetrievalError.invalidValue(value, for: Bool.self)
        }
    }

    public func toValue() -> ConfigSection.Value { return self ? "true" : "false" }
}

extension Numeric {
    public func toValue() -> ConfigSection.Value { return "\(self)" }
}

extension Int8: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Int8 {
        guard let int8 = Int8(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Int8.self)
        }

        return int8
    }
}

extension Int16: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Int16 {
        guard let int16 = Int16(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Int16.self)
        }

        return int16
    }
}

extension Int32: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Int32 {
        guard let int32 = Int32(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Int32.self)
        }

        return int32
    }
}

extension Int64: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Int64 {
        guard let int64 = Int64(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Int64.self)
        }

        return int64
    }
}

extension Int: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Int {
        guard let int = Int(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Int.self)
        }

        return int
    }
}

extension UInt8: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> UInt8 {
        guard let uint8 = UInt8(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: UInt8.self)
        }

        return uint8
    }
}

extension UInt16: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> UInt16 {
        guard let uint16 = UInt16(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: UInt16.self)
        }

        return uint16
    }
}

extension UInt32: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> UInt32 {
        guard let uint32 = UInt32(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: UInt32.self)
        }

        return uint32
    }
}

extension UInt64: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> UInt64 {
        guard let uint64 = UInt64(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: UInt64.self)
        }

        return uint64
    }
}

extension UInt: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> UInt {
        guard let uint = UInt(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: UInt.self)
        }

        return uint
    }
}

extension Double: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Double {
        guard let double = Double(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Double.self)
        }

        return double
    }
}

extension Float: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Float {
        guard let float = Float(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Float.self)
        }

        return float
    }
}

extension Float80: ConfigStorable {
    public static func from(value: ConfigSection.Value) throws -> Float80 {
        guard let float80 = Float80(value) else {
            throw ConfigRetrievalError.invalidValue(value, for: Float80.self)
        }

        return float80
    }
}

extension Array: ConfigRetrievable where Element: ConfigRetrievable {
    public static func from(value: ConfigSection.Value) throws -> [Element] {
        return try value.components(separatedBy: ",").map({ return try Element.from(value: $0.trimmingCharacters(in: .whitespaces)) })
    }
}

extension Array: ConfigStorable where Element: ConfigStorable {
    public func toValue() -> ConfigSection.Value {
        return map({ $0.toValue() }).joined(separator: ", ")
    }
}
