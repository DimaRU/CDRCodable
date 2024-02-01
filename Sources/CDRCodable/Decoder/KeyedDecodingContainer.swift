import Foundation

extension _CDRDecoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var dataStore: DataStore
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var allKeys: [Key] = []

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
        
        init(dataStore: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = dataStore
            self.dataStore.getCodingPath = {
                self.codingPath
            }
        }
    }
}

extension _CDRDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    func contains(_ key: Key) -> Bool {
        true
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        true
     }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try dataStore.read(UInt8.self) != 0
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try dataStore.readString()
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Numeric & Decodable {
        try dataStore.read(T.self)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        switch T.self {
        case is [Double].Type: return try dataStore.readArray(Double.self) as! T
        case is [Float].Type: return try dataStore.readArray(Float.self) as! T
        case is [Int].Type: return try dataStore.readArray(Int.self) as! T
        case is [Int8].Type: return try dataStore.readArray(Int8.self) as! T
        case is [Int16].Type: return try dataStore.readArray(Int16.self) as! T
        case is [Int32].Type: return try dataStore.readArray(Int32.self) as! T
        case is [Int64].Type: return try dataStore.readArray(Int64.self) as! T
        case is [UInt].Type: return try dataStore.readArray(UInt.self) as! T
        case is [UInt8].Type: return try dataStore.readArray(UInt8.self) as! T
        case is [UInt16].Type: return try dataStore.readArray(UInt16.self) as! T
        case is [UInt32].Type: return try dataStore.readArray(UInt32.self) as! T
        case is [UInt64].Type: return try dataStore.readArray(UInt64.self) as! T
        case is Data.Type:
            return try dataStore.readData() as! T
        default:
            let decoder = _CDRDecoder(dataStore: dataStore, userInfo: userInfo)
            return try T(from: decoder)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Nested unsupported")
        throw DecodingError.dataCorrupted(context)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Nested unsupported")
        throw DecodingError.dataCorrupted(context)
    }
    
    func superDecoder() throws -> Decoder {
        return _CDRDecoder(dataStore: dataStore, userInfo: userInfo)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _CDRDecoder(dataStore: dataStore, userInfo: userInfo)
        decoder.codingPath = [key]
        return decoder
    }
}

extension _CDRDecoder.KeyedContainer: _CDRDecodingContainer {}
