import Foundation

/// An object that decodes instances of a data type from Common Data Representation binary.
final public class CDRDecoder {
    public init() {}
    
    /**
     A dictionary you use to customize the decoding process
     by providing contextual information.
     */
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Returns a value of the type you specify, decoded from a Common Data Representation binary data
    /// - Parameters:
    ///   - type: The type of the value to decode
    ///   - data: Common Data Representation binary data, little endian
    /// - Returns: decoded object
    /// - Throws: `DecodingError.dataCorrupted(_:)` if the data is not valid
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let dataStore = DataStore(data: data)
        switch type {
        case is [Double].Type: return try dataStore.readArray(Double.self) as! T
        case is [Float].Type: return try dataStore.readArray(Float.self) as! T
        case is [Int].Type: return try dataStore.readArray(Int.self) as! T
        case is [Int8].Type: return try dataStore.readArray(Int8.self) as! T
        case is [Int16].Type: return try dataStore.readArray(Int16.self) as! T
        case is [Int32].Type: return try dataStore.readArray(Int32.self) as! T
        case is [Int64].Type: return try dataStore.readArray(Int64.self) as! T
        case is [UInt].Type: return try dataStore.readArray(UInt.self) as! T
        case is [UInt8].Type: return try dataStore.readArray(UInt8.self) as! T
        case is [UInt16].Type: return try dataStore.readArray(UInt16.self) as! T
        case is [UInt32].Type: return try dataStore.readArray(UInt32.self) as! T
        case is [UInt64].Type: return try dataStore.readArray(UInt64.self) as! T
        case is Data.Type:
            return try dataStore.readData() as! T
        default:
            let decoder = _CDRDecoder(dataStore: dataStore, userInfo: userInfo)
            return try T(from: decoder)
        }
    }
}

// MARK: -


final class DataStore {
    let data: Data
    let beginIndex: Data.Index
    var cursor: Data.Index
    var codingPath: [CodingKey] = []

    init(data: Data) {
        self.data = data
        self.beginIndex = self.data.startIndex
        self.cursor = self.data.startIndex
    }
}

final class _CDRDecoder {
    var codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey : Any]
    var container: _CDRDecodingContainer?
    var dataStore: DataStore
    
    init(dataStore: DataStore, userInfo: [CodingUserInfoKey : Any]) {
        self.dataStore = dataStore
        self.userInfo = userInfo
    }
}

extension _CDRDecoder: Decoder {
    func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {
        precondition(self.container == nil)

        let container = KeyedContainer<Key>(dataStore: dataStore, codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        precondition(self.container == nil)

        let container = try UnkeyedContainer(dataStore: dataStore, codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return container
    }
    
    func singleValueContainer() -> SingleValueDecodingContainer {
        precondition(self.container == nil)

        let container = SingleValueContainer(dataStore: dataStore, codingPath: codingPath, userInfo: userInfo)
        self.container = container
        
        return container
    }
}

protocol _CDRDecodingContainer {
    var codingPath: [CodingKey] { get }
    var userInfo: [CodingUserInfoKey : Any] { get }
    var dataStore: DataStore { get }
}

extension DataStore {
    @inline(__always)
    func align(to aligment: Int) {
        let offset = (cursor - beginIndex) % aligment
        if offset != 0 {
            cursor = cursor.advanced(by: aligment - offset)
        }
    }
    
    @inline(__always)
    func checkDataEnd(_ length: Int) throws {
        let nextIndex = cursor.advanced(by: length)
        guard nextIndex <= data.endIndex else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Unexpected end of data")
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
        align(to: MemoryLayout<T>.alignment)
        let stride = MemoryLayout<T>.stride
        try checkDataEnd(stride)
        defer {  
            cursor = cursor.advanced(by: stride)
        }
        return data.withUnsafeBytes{ $0.load(fromByteOffset: cursor - beginIndex, as: T.self) }
    }
    
    @inline(__always)
    func readString() throws -> String {
        let length = try readCheckBlockCount(of: 1)

        defer {
            cursor = cursor.advanced(by: length)
        }
        guard let string = String(data: data[cursor..<cursor.advanced(by: length - 1)], encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Couldn't decode string with UTF-8 encoding")
            throw DecodingError.dataCorrupted(context)
        }
        return string
    }
    
    @inline(__always)
    func readData() throws -> Data {
        let length = try readCheckBlockCount(of: 1)
        defer {
            cursor = cursor.advanced(by: length)
        }
        return data.subdata(in: cursor..<cursor.advanced(by: length))
    }

    @inline(__always)
    func readArray<T>(_ type: T.Type) throws -> [T] where T: Numeric {
        let size = MemoryLayout<T>.size
        let count = try readCheckBlockCount(of: size)
        defer {
            cursor = cursor.advanced(by: count * size)
        }
        return Array<T>.init(unsafeUninitializedCapacity: count) {
            let _: Int = data.copyBytes(to: $0, from: cursor...)
            $1 = count
        }
    }
    
    @inline(__always)
    func readFixedArray<T>(_ type: T.Type, count: Int) throws -> [T] where T: Numeric {
        align(to: MemoryLayout<T>.alignment)
        let stride = MemoryLayout<T>.stride
        try checkDataEnd(count * stride)
        defer {
            cursor = cursor.advanced(by: count * stride)
        }
        return Array<T>.init(unsafeUninitializedCapacity: count) {
            let _: Int = data.copyBytes(to: $0, from: cursor...)
            $1 = count
        }
    }
}
