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
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try readByte() != 0
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        let length = Int(try read(UInt32.self))
        let data = try read(length - 1)
        _ = try readByte()
        
        guard let string = String(data: data, encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Couldn't decode string with UTF-8 encoding")
            throw DecodingError.dataCorrupted(context)
        }
        return string
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        let bitPattern = try read(UInt64.self)
        return Double(bitPattern: bitPattern)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        let bitPattern = try read(UInt32.self)
        return Float(bitPattern: bitPattern)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : FixedWidthInteger & Decodable {
        guard let t = T(exactly: try read(T.self)) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid binary integer format")
            throw DecodingError.typeMismatch(T.self, context)
        }
        return t
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        if T.self is Data.Type {
            let length = Int(try read(UInt32.self))
            return try read(length) as! T
        }
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
