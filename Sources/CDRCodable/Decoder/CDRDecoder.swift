import Foundation

/**
 An object that decodes instances of a data type from CDRCodable objects.
 */
final public class CDRDecoder {
    public init() {}
    
    /**
     A dictionary you use to customize the decoding process
     by providing contextual information.
     */
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /**
     Returns a value of the type you specify,
     decoded from a CDRCodable object.
     
     - Parameters:
        - type: The type of the value to decode
                from the supplied CDRCodable object.
        - data: The CDRCodable object to decode.
     - Throws: `DecodingError.dataCorrupted(_:)`
               if the data is not valid CDRCodable.
     */
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let decoder = _CDRDecoder(data: _CDRDecoder.DataStore(data: data))
        decoder.userInfo = self.userInfo
        
        return try T(from: decoder)
    }
}

// MARK: -


final class _CDRDecoder {
    
    final class DataStore {
        let data: Data
        var index: Data.Index
        init(data: Data) {
            self.data = data
            self.index = self.data.startIndex
        }
    }
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var container: _CDRDecodingContainer?
    var dataStore: DataStore
    
    init(data: DataStore) {
        self.dataStore = data
    }
}

extension _CDRDecoder: Decoder {
    func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {
        precondition(self.container == nil)

        let container = KeyedContainer<Key>(data: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        precondition(self.container == nil)

        let container = UnkeyedContainer(data: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }
    
    func singleValueContainer() -> SingleValueDecodingContainer {
        precondition(self.container == nil)

        let container = SingleValueContainer(data: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}

protocol _CDRDecodingContainer {
    var codingPath: [CodingKey] { get set }
    var userInfo: [CodingUserInfoKey : Any] { get }
    var dataStore: _CDRDecoder.DataStore { get }
}

extension _CDRDecodingContainer {
    @inline(__always)
    func align(to aligment: Int) {
        let offset = self.dataStore.index % aligment
        if offset != 0 {
            self.dataStore.index = self.dataStore.index.advanced(by: aligment - offset)
        }
    }
    
    @inline(__always)
    func checkDataEnd(_ length: Int) throws {
        let nextIndex = self.dataStore.index.advanced(by: length)
        guard nextIndex <= self.dataStore.data.endIndex else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unexpected end of data")
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    @inline(__always)
    func readCheckBlockCount(of size: Int) throws -> Int {
        let length = Int(try read(UInt32.self))
        try checkDataEnd(length * size)
        return length
    }
    
    @inline(__always)
    func read<T>(_ type: T.Type) throws -> T where T : Numeric {
        let aligment = MemoryLayout<T>.alignment
        let offset = self.dataStore.index % aligment
        if offset != 0 {
            self.dataStore.index = self.dataStore.index.advanced(by: aligment - offset)
        }
        let stride = MemoryLayout<T>.stride
        try checkDataEnd(stride)
        defer {  
            dataStore.index = dataStore.index.advanced(by: stride)
        }
        return dataStore.data.withUnsafeBytes{ $0.load(fromByteOffset: dataStore.index, as: T.self) }
    }

    @inline(__always)
    func readArray<T>(_ type: T.Type) throws -> [T] where T: Numeric {
        let size = MemoryLayout<T>.size
        let count = try readCheckBlockCount(of: size)
        defer {
            dataStore.index = dataStore.index.advanced(by: count * size)
        }
        return Array<T>.init(unsafeUninitializedCapacity: count) {
            dataStore.data.copyBytes(to: $0, from: dataStore.index...)
            $1 = count
        }
    }
    
    @inline(__always)
    func readString() throws -> String {
        let length = try readCheckBlockCount(of: 1)

        defer {
            dataStore.index = dataStore.index.advanced(by: length)
        }
        guard let string = String(data: dataStore.data[dataStore.index..<dataStore.index.advanced(by: length - 1)], encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Couldn't decode string with UTF-8 encoding")
            throw DecodingError.dataCorrupted(context)
        }
        return string
    }
    
    @inline(__always)
    func readData() throws -> Data {
        let length = try readCheckBlockCount(of: 1)
        defer {
            dataStore.index = dataStore.index.advanced(by: length)
        }
        return dataStore.data.subdata(in: dataStore.index..<dataStore.index.advanced(by: length))
    }
}
