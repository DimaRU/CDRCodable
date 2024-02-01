import Foundation

extension _CDRDecoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var dataStore: DataStore
        
        init(data: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = data
            self.dataStore.getCodingPath = {
                self.codingPath
            }
            count = Int(try dataStore.read(UInt32.self))
        }

        var count: Int?
        var currentIndex: Int = 0
        var isAtEnd: Bool {
            currentIndex >= count!
        }
    }
}

extension _CDRDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        return true
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { self.currentIndex += 1 }
        let decoder = _CDRDecoder(dataStore: self.dataStore, userInfo: userInfo)
        let value = try T(from: decoder)
        return value
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Nested unsupported")
        throw DecodingError.dataCorrupted(context)
    }
    
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Nested unsupported")
        throw DecodingError.dataCorrupted(context)
    }

    func superDecoder() throws -> Decoder {
        return _CDRDecoder(dataStore: dataStore, userInfo: userInfo)
    }
}

extension _CDRDecoder.UnkeyedContainer: _CDRDecodingContainer {}
