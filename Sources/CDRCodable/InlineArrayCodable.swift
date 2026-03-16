/////
////  InlineArrayCodable.swift
///   Copyright © 2026 Dmitriy Borovikov. All rights reserved.
//

import Foundation

extension InlineArray: @retroactive Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let encoder = encoder as? _CDREncoder {
            let dataStore = encoder.dataStore
            switch Element.self {
            case is Double.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Double>) }
            case is Float.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Float>) }
            case is Int.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Int>) }
            case is Int8.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Int8>) }
            case is Int16.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Int16>) }
            case is Int32.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Int32>) }
            case is Int64.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<Int64>) }
            case is UInt.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<UInt>) }
            case is UInt8.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<UInt8>) }
            case is UInt16.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<UInt16>) }
            case is UInt32.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<UInt32>) }
            case is UInt64.Type: span.withUnsafeBufferPointer { dataStore.encodeArray(pointer: $0 as! UnsafeBufferPointer<UInt64>) }
            default:
                var container = encoder.singleValueContainer()
                for index in indices {
                    try container.encode(self[index])
                }
            }
        } else {
            var container = encoder.singleValueContainer()
            for index in indices {
                try container.encode(self[index])
            }
        }
    }
}

extension InlineArray: @retroactive Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        if let decoder = decoder as? _CDRDecoder {
            let ds = decoder.dataStore
            switch Element.self {
            case is Double.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is Float.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is Int.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is Int8.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is Int16.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is Int32.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is Int64.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is UInt.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is UInt8.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is UInt16.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is UInt32.Type: self = try .init{ try ds.readFixedArray(&$0) }
            case is UInt64.Type: self = try .init{ try ds.readFixedArray(&$0) }
            default:
                let container = decoder.singleValueContainer()
                self = try .init { _ in try container.decode(Element.self) }
            }
        } else {
            let container = try decoder.singleValueContainer()
            self = try .init { _ in try container.decode(Element.self) }
        }
    }
}
