import Foundation

/**
 An object that encodes instances of a data type as CDRCodable objects.
 */
final public class CDREncoder {
    public init() {}
    
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /**
     Returns a CDRCodable-encoded representation of the value you supply.
     
     - Parameters:
        - value: The value to encode as CDRCodable.
     - Throws: `EncodingError.invalidValue(_:_:)`
                if the value can't be encoded as a CDRCodable object.
     */
    public func encode(_ value: Encodable) throws -> Data {
        var capacity = MemoryLayout.size(ofValue: value)
        capacity = capacity + capacity / 10 + 8
        let dataBlock = _CDREncoder.DataBlock(capacity: capacity)
        var encoder: _CDREncoder? = _CDREncoder(data: dataBlock)
        encoder!.userInfo = self.userInfo

        switch value {
        case let data as Data:
            try Box<Data>(data).encode(to: encoder!)
        default:
            try value.encode(to: encoder!)
        }
        
        encoder = nil
        let aligment = dataBlock.data.count % 4
        if aligment != 0 {
            for _ in 0..<4-aligment {
                dataBlock.data.append(0)
            }
        }
        return dataBlock.data
    }
}

// MARK: -

protocol _CDREncodingContainer {
    var data: _CDREncoder.DataBlock { get }
}

class _CDREncoder {
    final class DataBlock {
        var data: Data
        init(capacity: Int) {
            data = Data(capacity: capacity)
        }
    }
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    fileprivate var container: _CDREncodingContainer?
    var data: DataBlock
    
    init(data: DataBlock) {
        self.data = data
    }
}

extension _CDREncoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()
        
        let container = KeyedContainer<Key>(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()
        
        let container = UnkeyedContainer(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()
        
        let container = SingleValueContainer(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}

extension _CDREncodingContainer {
    func write(data: Data) {
        self.data.data.append(data)
    }
    
    func writeByte(_ byte: UInt8) {
        self.data.data.append(byte)
    }
    
    func write<T>(value: T) where T: FixedWidthInteger {
        let aligment = MemoryLayout<T>.alignment
        let offset = self.data.data.count % aligment
        if offset != 0 {
            self.data.data.append(contentsOf: Array(repeating: UInt8(0), count: aligment - offset))
        }
        self.data.data.append(contentsOf: value.bytes)
    }
}
