import Foundation

extension _CDREncoder {
    struct KeyedContainer<Key> where Key: CodingKey {
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
    private func encodeNumericArray(count: Int, pointer: UnsafeRawBufferPointer) throws {
        try write(count: count)
        dataStore.data.append(pointer.baseAddress!.assumingMemoryBound(to: UInt8.self), count: pointer.count)
    }

    @inline(__always)
    private func encodeFixedNumericArray(alignment: Int, count: Int, fixedCount:Int, pointer: UnsafeRawBufferPointer) throws {
        guard fixedCount == count else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Wrong fixed array size.")
            throw EncodingError.invalidValue(count, context)
        }
        dataStore.align(alignment)
        dataStore.data.append(pointer.baseAddress!.assumingMemoryBound(to: UInt8.self), count: pointer.count)
    }
    @inline(__always)
    private func writeString(_ s: String) throws {
        guard let data = s.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(s, context)
        }
        let length = data.count + 1

        try write(count: length)
        dataStore.write(data: data)
        dataStore.writeByte(0)
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
        try writeString(value)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Numeric & Encodable {
        dataStore.write(value: value)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if let intValue = key.intValue, intValue > 0x10000 {
            let fixedCount = intValue >> 16
            switch value {
            case let value as [Int]: try encodeFixedNumericArray(alignment: MemoryLayout<Int>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [Int8]: try encodeFixedNumericArray(alignment: MemoryLayout<Int8>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [Int16]: try encodeFixedNumericArray(alignment: MemoryLayout<Int16>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [Int32]: try encodeFixedNumericArray(alignment: MemoryLayout<Int32>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [Int64]: try encodeFixedNumericArray(alignment: MemoryLayout<Int64>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [UInt]: try encodeFixedNumericArray(alignment: MemoryLayout<UInt>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [UInt8]: try encodeFixedNumericArray(alignment: MemoryLayout<UInt8>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [UInt16]: try encodeFixedNumericArray(alignment: MemoryLayout<UInt16>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [UInt32]: try encodeFixedNumericArray(alignment: MemoryLayout<UInt32>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [UInt64]: try encodeFixedNumericArray(alignment: MemoryLayout<UInt64>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [Float]: try encodeFixedNumericArray(alignment: MemoryLayout<Float>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [Double]: try encodeFixedNumericArray(alignment: MemoryLayout<Double>.alignment, count: value.count, fixedCount: fixedCount, pointer: value.withUnsafeBytes{ $0 })
            case let value as [String]:
                guard fixedCount == value.count else {
                    let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Wrong fixed array size.")
                    throw EncodingError.invalidValue(value.count, context)
                }
                for string in value {
                    try writeString(string)
                }
            default:
                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Non-collection value as fixed array")
                throw EncodingError.invalidValue(value, context)
            }
            return
        }
        switch value {
        case let value as [Int]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int8]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int16]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int32]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int64]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt8]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt16]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt32]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt64]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Float]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Double]: try encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
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

extension _CDREncoder.KeyedContainer: _CDREncodingContainer {
    func closeContainer() {}
}
