/////
////  CDREncoder.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

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
        let dataStore = _CDREncoder.DataStore(capacity: capacity)

        switch value {
        case let value as [Int]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int8]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int16]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int32]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Int64]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt8]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt16]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt32]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [UInt64]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Float]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as [Double]: try dataStore.encodeNumericArray(count: value.count, pointer: value.withUnsafeBytes{ $0 })
        case let value as Data:
            try dataStore.write(count: value.count)
            dataStore.write(data: value)
        default:
            let encoder: _CDREncoder = _CDREncoder(data: dataStore)
            encoder.userInfo = self.userInfo
            try value.encode(to: encoder)
        }

        // Final data aligment
        let aligment = dataStore.data.count % 4
        if aligment != 0 {
            for _ in 0..<4-aligment {
                dataStore.data.append(0)
            }
        }
        return dataStore.data
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
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        precondition(self.container == nil)

        let container = KeyedContainer<Key>(data: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        precondition(self.container == nil)

        let container = UnkeyedContainer(dataStore: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        precondition(self.container == nil)

        let container = SingleValueContainer(dataStore: self.dataStore, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}

extension _CDREncoder.DataStore {
    func align(_ alignment: Int) {
        let offset = self.data.count % alignment
        if offset != 0 {
            self.data.append(contentsOf: Array(repeating: UInt8(0), count: alignment - offset))
        }
    }
    
    @inline(__always)
    func write(data: Data) {
        self.data.append(data)
    }
    
    @inline(__always)
    func writeByte(_ byte: UInt8) {
        self.data.append(byte)
    }
    
    @inline(__always)
    func write<T>(value: T) where T: Numeric {
        let alignment = MemoryLayout<T>.alignment
        let offset = self.data.count % alignment
        if offset != 0 {
            self.data.append(contentsOf: Array(repeating: UInt8(0), count: alignment - offset))
        }
        self.data.append(contentsOf: value.bytes)
    }
    
    func write(count: Int) throws {
        guard let uint32 = UInt32(exactly: count) else {
            let context = EncodingError.Context(codingPath: [], debugDescription: "Cannot encode data of length \(count).")
            throw EncodingError.invalidValue(count, context)
        }
        write(value: uint32)
    }
    
    @inline(__always)
    func encodeNumericArray(count: Int, pointer: UnsafeRawBufferPointer) throws {
        guard let uint32 = UInt32(exactly: count) else {
            let context = EncodingError.Context(codingPath: [], debugDescription: "Cannot encode data of length \(count).")
            throw EncodingError.invalidValue(count, context)
        }
        write(value: uint32)
        data.append(pointer.baseAddress!.assumingMemoryBound(to: UInt8.self), count: pointer.count)
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
