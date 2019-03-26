public extension ConfigSection {
    func getString(key: Key) -> String? {
        return self[key]
    }

    func getBool(key: Key) throws -> Bool? {
        return try get(key: key)
    }

    func getInt8(key: Key) throws -> Int8? {
        return try get(key: key)
    }

    func getInt16(key: Key) throws -> Int16? {
        return try get(key: key)
    }

    func getInt32(key: Key) throws -> Int32? {
        return try get(key: key)
    }

    func getInt64(key: Key) throws -> Int64? {
        return try get(key: key)
    }

    func getInt(key: Key) throws -> Int? {
        return try get(key: key)
    }

    func getUInt8(key: Key) throws -> UInt8? {
        return try get(key: key)
    }

    func getUInt16(key: Key) throws -> UInt16? {
        return try get(key: key)
    }

    func getUInt32(key: Key) throws -> UInt32? {
        return try get(key: key)
    }

    func getUInt64(key: Key) throws -> UInt64? {
        return try get(key: key)
    }

    func getUInt(key: Key) throws -> UInt? {
        return try get(key: key)
    }

    func getDouble(key: Key) throws -> Double? {
        return try get(key: key)
    }

    func getFloat(key: Key) throws -> Float? {
        return try get(key: key)
    }

    func getFloat80(key: Key) throws -> Float80? {
        return try get(key: key)
    }
}
