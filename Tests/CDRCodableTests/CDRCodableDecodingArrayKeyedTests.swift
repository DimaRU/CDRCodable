/////
////  CDRCodableDecodingArrayKeyedTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodableDecodingArrayKeyedTests: XCTestCase {
    var decoder: CDRDecoder!
    
    override func setUp() {
        self.decoder = CDRDecoder()
    }
    
    func testDecodeData() {
        struct TestStruct: Codable, Equatable {
            let b: UInt8
            let s: Data
        }
        let value = TestStruct(b: 0x55, s: "hello".data(using: .utf8)!)
        let data = Data([0x55, 0, 0, 0, 5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }
    
    func testDecodeArray8() {
        struct TestStruct: Codable, Equatable {
            let b: UInt8
            let a: [Int8]
        }
        let value = TestStruct(b: 0x55, a: [-1, 2, 3])
        let data = Data([0x55, 0, 0, 0, 3, 0, 0, 0, 0xff, 2, 3, 0])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }
    
    func testDecodeArray16() {
        struct TestStruct: Codable, Equatable {
            let b: UInt8
            let a: [Int16]
        }
        let value = TestStruct(b: 0x55, a: [-1, 2, 3])
        let data = Data([0x55, 0, 0, 0, 3, 0, 0, 0, 0xff, 0xff, 2, 0, 3, 0, 0, 0])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }
    
    func testDecodeArray32() {
        struct TestStruct: Codable, Equatable {
            let b: UInt8
            let a: [Int32]
        }
        let value = TestStruct(b: 0x55, a: [-1, 2, 3])
        let data = Data([0x55, 0, 0, 0, 3, 0, 0, 0, 0xff, 0xff, 0xff, 0xff, 2, 0, 0, 0, 3, 0, 0, 0])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }
    
    func testDecodeArray64() {
        struct TestStruct: Codable, Equatable {
            let a: [Int64]
        }
        let value = TestStruct(a: [-1, 2, 3])
        let data = Data([3, 0, 0, 0,
                                   0, 0, 0, 0,
                                   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                                   2, 0, 0, 0, 0, 0, 0, 0,
                                   3, 0, 0, 0, 0, 0, 0, 0])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }
    
    func testDecodeArrayFloat() {
        struct TestStruct: Codable, Equatable {
            let b: UInt8
            let a: [Float]
        }
        let value = TestStruct(b: 0x55, a: [1, 2, 3])
        let data = Data([0x55, 0, 0, 0,
                                   3, 0, 0, 0,
                                   0, 0, 0x80, 0x3f,
                                   0, 0, 0, 0x40,
                                   0, 0, 0x40, 0x40])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }
    
    func testDecodeArrayDouble() {
        struct TestStruct: Codable, Equatable {
            let a: [Double]
        }
        let value = TestStruct(a: [1, 2, 3])
        let data = Data([3, 0, 0, 0,
                                   0, 0, 0, 0,
                                   0, 0, 0, 0, 0, 0, 0xf0, 0x3f,
                                   0, 0, 0, 0, 0, 0, 0, 0x40,
                                   0, 0, 0, 0, 0, 0, 8, 0x40])
        let decoded = try! decoder.decode(TestStruct.self, from: data)
        XCTAssertEqual(value, decoded)
    }

}
