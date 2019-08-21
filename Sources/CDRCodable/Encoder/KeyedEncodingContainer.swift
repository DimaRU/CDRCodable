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
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
//        print("Keyed: ", String(describing: T.self))
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
