import Foundation

extension _CDREncoder {
    final class UnkeyedContainer {
        var count: Int = 0
        private var index: Data.Index
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var data: DataBlock

        init(data: DataBlock, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
            let count: UInt32 = 0
            self.index = data.data.endIndex
            write(value: count)
            self.index = data.data.endIndex
        }
        
        deinit {
            if let count32 = UInt32(exactly: count) {
                let range = index-4..<index
                self.data.data.replaceSubrange(range, with: count32.bigEndian.bytes)
            }
        }
    }
}

extension _CDREncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
//        print("Unkeyed: ", String(describing: T.self))
        defer { count += 1 }
        let encoder = _CDREncoder(data: self.data)
        try value.encode(to: encoder)
    }
    
    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Unimplemented")
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Unimplemented")
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }
    
    func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }
}

extension _CDREncoder.UnkeyedContainer: _CDREncodingContainer {}
