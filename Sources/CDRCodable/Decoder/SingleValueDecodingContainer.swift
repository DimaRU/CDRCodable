import Foundation

extension _CDRDecoder {
    final class SingleValueContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var dataStore: DataStore

        init(data: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = data
        }
    }
}

extension _CDRDecoder.SingleValueContainer: SingleValueDecodingContainer {    
    func decodeNil() -> Bool {
        true
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try read(UInt8.self) != 0
    }
    
    func decode(_ type: String.Type) throws -> String {
        try readString()
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Numeric & Decodable {
        try read(T.self)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case is Data.Type:
            return try readData() as! T
        default:
            let decoder = _CDRDecoder(data: self.dataStore)
            return try T(from: decoder)
        }
    }
}

extension _CDRDecoder.SingleValueContainer: _CDRDecodingContainer {}
