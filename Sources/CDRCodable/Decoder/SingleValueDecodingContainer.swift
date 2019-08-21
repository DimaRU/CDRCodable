import Foundation

extension _CDRDecoder {
    final class SingleValueContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var data: DataBlock

        init(data: DataBlock, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
        }
        
//        func checkCanDecode<T>(_ type: T.Type) throws {
//            guard self.index <= self.data.endIndex else {
//                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of data")
//            }
//        }
    }
}

extension _CDRDecoder.SingleValueContainer: SingleValueDecodingContainer {    
    func decodeNil() -> Bool {
        return true
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        return try readByte() != 0
    }
    
    func decode(_ type: String.Type) throws -> String {
        let length = Int(try read(UInt32.self))
        let data = try read(length - 1)
        _ = try readByte()
        
        guard let string = String(data: data, encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Couldn't decode string with UTF-8 encoding")
            throw DecodingError.dataCorrupted(context)
        }
        return string
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        let bitPattern = try read(UInt64.self)
        return Double(bitPattern: bitPattern)
    }

    func decode(_ type: Float.Type) throws -> Float {
        let bitPattern = try read(UInt32.self)
        return Float(bitPattern: bitPattern)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : FixedWidthInteger & Decodable {
        guard let t = T(exactly: try read(T.self)) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid binary integer format")
            throw DecodingError.typeMismatch(T.self, context)
        }
        return t
    }

    func decode(_ type: Data.Type) throws -> Data {
        let length = Int(try read(UInt32.self))
        return self.data.data.subdata(in: self.data.index..<self.data.index.advanced(by: length))
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case is Data.Type:
            return try decode(Data.self) as! T
        default:
            let decoder = _CDRDecoder(data: self.data)
            let value = try T(from: decoder)
            return value
        }
    }
}

extension _CDRDecoder.SingleValueContainer: _CDRDecodingContainer {}
