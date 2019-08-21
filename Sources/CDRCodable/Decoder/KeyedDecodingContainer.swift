import Foundation

extension _CDRDecoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var data: DataBlock
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var allKeys: [Key] = []

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

extension _CDRDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    func contains(_ key: Key) -> Bool {
        return true
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return true
     }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let decoder = _CDRDecoder(data: self.data)
        let value = try T(from: decoder)
        return value
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Nested unsupported")
        throw DecodingError.dataCorrupted(context)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Nested unsupported")
        throw DecodingError.dataCorrupted(context)
    }
    
    func superDecoder() throws -> Decoder {
        return _CDRDecoder(data: self.data)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _CDRDecoder(data: self.data)
        decoder.codingPath = [key]
        return decoder
    }
}

extension _CDRDecoder.KeyedContainer: _CDRDecodingContainer {}
