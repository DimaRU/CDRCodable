import Foundation

extension _CDRDecoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var dataStore: DataStore
        
        lazy var count: Int? = {
            do {
                return Int(try read(UInt32.self))
            } catch {
                return nil
            }
        } ()
    
        var currentIndex: Int = 0
        
       
        init(data: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = data
        }
        
        var isAtEnd: Bool {
            guard let count = self.count else {
                return true
            }
            return currentIndex >= count
        }
    }
}

extension _CDRDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        return true
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { self.currentIndex += 1 }
        let decoder = _CDRDecoder(data: self.dataStore)
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
        return _CDRDecoder(data: self.dataStore)
    }
}

extension _CDRDecoder.UnkeyedContainer: _CDRDecodingContainer {}
