import Foundation

extension _CDREncoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var dataStore: DataStore
        
        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
        
        init(data: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = data
        }
    }
}

extension _CDREncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    @inline(__always)
    private func encodeNumericArray(count: Int, size: Int, pointer: UnsafeRawBufferPointer) throws {
        try write(count: count)
        dataStore.data.append(pointer.baseAddress!.assumingMemoryBound(to: UInt8.self), count: count * size)
    }

    // Ignoring optionals as having no analog in the CDR protocol
    func encodeNil(forKey key: Key) throws {}
    func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: String?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Double?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Float?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Int?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {}
    func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {}
    func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {}
    
    
    func encode(_ value: Bool, forKey key: Key) throws {
        switch value {
        case false:
            dataStore.writeByte(0)
        case true:
            dataStore.writeByte(1)
        }
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        guard let data = value.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(value, context)
        }
        let length = data.count + 1

        try write(count: length)
        dataStore.write(data: data)
        dataStore.writeByte(0)
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        dataStore.write(value: value.bitPattern)
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        dataStore.write(value: value.bitPattern)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : FixedWidthInteger & Encodable {
        dataStore.write(value: value)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        switch value {
        case let value as [Int]: try encodeNumericArray(count: value.count, size: MemoryLayout<Int>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int8]: try encodeNumericArray(count: value.count, size: MemoryLayout<Int8>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int16]: try encodeNumericArray(count: value.count, size: MemoryLayout<Int16>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int32]: try encodeNumericArray(count: value.count, size: MemoryLayout<Int32>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int64]: try encodeNumericArray(count: value.count, size: MemoryLayout<Int64>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt]: try encodeNumericArray(count: value.count, size: MemoryLayout<UInt>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt8]: try encodeNumericArray(count: value.count, size: MemoryLayout<UInt8>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt16]: try encodeNumericArray(count: value.count, size: MemoryLayout<UInt16>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt32]: try encodeNumericArray(count: value.count, size: MemoryLayout<UInt32>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt64]: try encodeNumericArray(count: value.count, size: MemoryLayout<UInt64>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Float]: try encodeNumericArray(count: value.count, size: MemoryLayout<Float>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Double]: try encodeNumericArray(count: value.count, size: MemoryLayout<Double>.size, pointer: value.withUnsafeBytes{ $0 })
        case let value as Data:
            try write(count: value.count)
            dataStore.write(data: value)
        default:
            let encoder = _CDREncoder(data: self.dataStore)
            try value.encode(to: encoder)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _CDREncoder.UnkeyedContainer(dataStore: self.dataStore, codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CDREncoder.KeyedContainer<NestedKey>(data: self.dataStore, codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        return KeyedEncodingContainer(container)
    }
    
    func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Unimplemented")
    }
}

extension _CDREncoder.KeyedContainer: _CDREncodingContainer {}
