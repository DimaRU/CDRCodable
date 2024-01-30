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
        let dataBlock = _CDREncoder.DataStore(capacity: capacity)
        var encoder: _CDREncoder? = _CDREncoder(data: dataBlock)
        encoder!.userInfo = self.userInfo

        try value.encode(to: encoder!)

        encoder = nil       // call deinit and finalize dataBlock changes.
        // Final data aligment
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
    var dataStore: _CDREncoder.DataStore { get }
    var codingPath: [CodingKey] { get set }
    func write(count: Int) throws
}

final class _CDREncoder {
    final class DataStore {
        var data: Data
        init(capacity: Int) {
            data = Data(capacity: capacity)
        }
    }
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    fileprivate var container: _CDREncodingContainer?
    var dataStore: DataStore
    
    init(data: DataStore) {
        self.dataStore = data
    }
}

extension _CDREncoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()
        
        let container = KeyedContainer<Key>(data: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()
        
        let container = UnkeyedContainer(dataStore: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()
        
        let container = SingleValueContainer(dataStore: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}

extension _CDREncoder.DataStore {
    @inline(__always)
    func write(data: Data) {
        self.data.append(data)
    }
    
    @inline(__always)
    func writeByte(_ byte: UInt8) {
        self.data.append(byte)
    }
    
    @inline(__always)
    func write<T>(value: T) where T: FixedWidthInteger {
        let aligment = MemoryLayout<T>.alignment
        let offset = self.data.count % aligment
        if offset != 0 {
            self.data.append(contentsOf: Array(repeating: UInt8(0), count: aligment - offset))
        }
        self.data.append(contentsOf: value.bytes)
    }
}

extension _CDREncodingContainer {
    func write(count: Int) throws {
        guard let uint32 = UInt32(exactly: count) else {
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode data of length \(count).")
            throw EncodingError.invalidValue(count, context)
        }
        dataStore.write(value: uint32)
    }
}
