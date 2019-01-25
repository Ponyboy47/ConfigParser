extension ConfigSection {
    public func getString(key: Key) -> String? {
        return self[key]
    }

    public func getBool(key: Key) throws -> Bool? {
        return try get(key: key)
    }

    public func getInt8(key: Key) throws -> Int8? {
        return try get(key: key)
    }

    public func getInt16(key: Key) throws -> Int16? {
        return try get(key: key)
    }

    public func getInt32(key: Key) throws -> Int32? {
        return try get(key: key)
    }

    public func getInt64(key: Key) throws -> Int64? {
        return try get(key: key)
    }

    public func getInt(key: Key) throws -> Int? {
        return try get(key: key)
    }

    public func getUInt8(key: Key) throws -> UInt8? {
        return try get(key: key)
    }

    public func getUInt16(key: Key) throws -> UInt16? {
        return try get(key: key)
    }

    public func getUInt32(key: Key) throws -> UInt32? {
        return try get(key: key)
    }

    public func getUInt64(key: Key) throws -> UInt64? {
        return try get(key: key)
    }

    public func getUInt(key: Key) throws -> UInt? {
        return try get(key: key)
    }

    public func getDouble(key: Key) throws -> Double? {
        return try get(key: key)
    }

    public func getFloat(key: Key) throws -> Float? {
        return try get(key: key)
    }

    public func getFloat80(key: Key) throws -> Float80? {
        return try get(key: key)
    }
}
