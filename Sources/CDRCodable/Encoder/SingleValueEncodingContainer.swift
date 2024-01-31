import Foundation

extension _CDREncoder {
   struct SingleValueContainer: _CDREncodingContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var dataStore: DataStore
        
        init(dataStore: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = dataStore
        }
        func closeContainer() {}
    }
}

extension _CDREncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {}
    
    func encode(_ value: Bool) throws {
        switch value {
        case false:
            dataStore.writeByte(0)
        case true:
            dataStore.writeByte(1)
        }
    }
    
    func encode(_ value: String) throws {
        guard let data = value.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
            throw EncodingError.invalidValue(value, context)
        }
        let length = data.count + 1

        try write(count: length)
        dataStore.write(data: data)
        dataStore.writeByte(0)
    }
    
    func encode<T>(_ value: T) throws where T : Numeric & Encodable {
        dataStore.write(value: value)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let data as Data:
            try write(count: data.count)
            dataStore.write(data: data)
        default:
            let encoder = _CDREncoder(data: self.dataStore)
            try value.encode(to: encoder)
        }
    }
}
