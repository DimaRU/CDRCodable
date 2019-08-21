import Foundation

extension _CDREncoder {
    final class SingleValueContainer {
        fileprivate var canEncodeNewValue = true
        fileprivate func checkCanEncode(value: Any?) throws {
            guard self.canEncodeNewValue else {
                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Attempt to encode value through single value container when previously value already encoded.")
                throw EncodingError.invalidValue(value as Any, context)
            }
        }
        
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
        try checkCanEncode(value: nil)
        defer { self.canEncodeNewValue = false }

        switch value {
        case false:
            writeByte(0)
        case true:
            writeByte(1)
        }
    }
    
    func encode(_ value: String) throws {
//        print("Single string: ", value)
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }
        
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
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }
        write(value: value.bitPattern)
    }
    
    func encode(_ value: Float) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }
        write(value: value.bitPattern)
    }
    
    func encode<T>(_ value: T) throws where T : FixedWidthInteger & Encodable {
//        print("Single: ", String(describing: T.self))
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }
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
//        print("Single: ", String(describing: T.self))
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }
        
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
