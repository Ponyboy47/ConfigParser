public extension ConfigSection {
    func getString(key: Key) -> String? {
        return self[key]
    }

    func getBool(key: Key) -> Bool? {
        return get(key: key)
    }

    func getInt8(key: Key) -> Int8? {
        return get(key: key)
    }

    func getInt16(key: Key) -> Int16? {
        return get(key: key)
    }

    func getInt32(key: Key) -> Int32? {
        return get(key: key)
    }

    func getInt64(key: Key) -> Int64? {
        return get(key: key)
    }

    func getInt(key: Key) -> Int? {
        return get(key: key)
    }

    func getUInt8(key: Key) -> UInt8? {
        return get(key: key)
    }

    func getUInt16(key: Key) -> UInt16? {
        return get(key: key)
    }

    func getUInt32(key: Key) -> UInt32? {
        return get(key: key)
    }

    func getUInt64(key: Key) -> UInt64? {
        return get(key: key)
    }

    func getUInt(key: Key) -> UInt? {
        return get(key: key)
    }

    func getDouble(key: Key) -> Double? {
        return get(key: key)
    }

    func getFloat(key: Key) -> Float? {
        return get(key: key)
    }

    func getFloat80(key: Key) -> Float80? {
        return get(key: key)
    }
}
