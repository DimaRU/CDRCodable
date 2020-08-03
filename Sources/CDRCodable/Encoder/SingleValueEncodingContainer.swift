import Foundation

extension _CDREncoder {
    final class SingleValueContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var data: DataBlock
        
        init(data: DataBlock, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
        }
    }
}

extension _CDREncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
    }
    
    func encode(_ value: Bool) throws {
        switch value {
        case false:
            writeByte(0)
        case true:
            writeByte(1)
        }
    }
    
    func encode(_ value: String) throws {
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
    
    func encode(_ value: Double) throws {
        write(value: value.bitPattern)
    }
    
    func encode(_ value: Float) throws {
        write(value: value.bitPattern)
    }
    
    func encode<T>(_ value: T) throws where T : FixedWidthInteger & Encodable {
        write(value: value)
    }

    func encode(_ value: Data) throws {
        let length = value.count
        if let uint32 = UInt32(exactly: length) {
            write(value: uint32)
            write(data: value)
        } else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode data of length \(value.count).")
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let data as Data:
            try self.encode(data)
        default:
            let encoder = _CDREncoder(data: self.data)
            try value.encode(to: encoder)
        }
    }
}

extension _CDREncoder.SingleValueContainer: _CDREncodingContainer {}
