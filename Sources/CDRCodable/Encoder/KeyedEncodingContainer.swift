import Foundation

extension _CDREncoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var data: DataBlock
        
        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
        
        init(data: DataBlock, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
        }
    }
}

extension _CDREncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
    }

    func encode(_ value: Bool, forKey key: Key) throws {
        switch value {
        case false:
            writeByte(0)
        case true:
            writeByte(1)
        }
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        guard let data = value.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(value, context)
        }
        let length = data.count + 1

        if let uint32 = UInt32(exactly: length) {
            write(value: uint32)
        } else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string with length \(length).")
            throw EncodingError.invalidValue(value, context)
        }
        write(data: data)
        writeByte(0)
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        write(value: value.bitPattern)
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        write(value: value.bitPattern)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : FixedWidthInteger & Encodable {
        write(value: value)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if let value = value as? Data {
            let length = value.count
            if let uint32 = UInt32(exactly: length) {
                write(value: uint32)
                write(data: value)
            } else {
                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode data of length \(value.count).")
                throw EncodingError.invalidValue(value, context)
            }
            return
        }

        let encoder = _CDREncoder(data: self.data)
        try value.encode(to: encoder)
    }
    
    private func nestedSingleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
        let container = _CDREncoder.SingleValueContainer(data: self.data, codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        return container
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _CDREncoder.UnkeyedContainer(data: self.data, codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _CDREncoder.KeyedContainer<NestedKey>(data: self.data, codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
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
