/////
////  CDRCodableEncodingArrayKeyedTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodableEncodingArrayKeyedTests: XCTestCase {
    var encoder: CDREncoder!
    
    override func setUp() {
        self.encoder = CDREncoder()
    }
    
    func testEncodeData() {
        struct TestStruct: Codable {
            let b: UInt8
            let s: Data
        }
        let value = TestStruct(b: 0x55, s: "hello".data(using: .utf8)!)
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([0x55, 0, 0, 0, 5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0]))
    }
    
    func testEncodeArray8() {
        struct TestStruct: Codable {
            let b: UInt8
            let a: [Int8]
        }
        let value = TestStruct(b: 0x55, a: [-1, 2, 3])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([0x55, 0, 0, 0, 3, 0, 0, 0, 0xff, 2, 3, 0]))
    }
    
    func testEncodeArray16() {
        struct TestStruct: Codable {
            let b: UInt8
            let a: [Int16]
        }
        let value = TestStruct(b: 0x55, a: [-1, 2, 3])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([0x55, 0, 0, 0, 3, 0, 0, 0, 0xff, 0xff, 2, 0, 3, 0, 0, 0]))
    }
    
    func testEncodeArray32() {
        struct TestStruct: Codable {
            let b: UInt8
            let a: [Int32]
        }
        let value = TestStruct(b: 0x55, a: [-1, 2, 3])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([0x55, 0, 0, 0, 3, 0, 0, 0, 0xff, 0xff, 0xff, 0xff, 2, 0, 0, 0, 3, 0, 0, 0]))
    }
    
    func testEncodeArray64() {
        struct TestStruct: Codable {
            let a: [Int64]
        }
        let value = TestStruct(a: [-1, 2, 3])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([3, 0, 0, 0,
                                   0, 0, 0, 0,
                                   0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                                   2, 0, 0, 0, 0, 0, 0, 0,
                                   3, 0, 0, 0, 0, 0, 0, 0]))
    }
    
    func testEncodeArrayFloat() {
        struct TestStruct: Codable {
            let b: UInt8
            let a: [Float]
        }
        let value = TestStruct(b: 0x55, a: [1, 2, 3])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([0x55, 0, 0, 0,
                                   3, 0, 0, 0,
                                   0, 0, 0x80, 0x3f,
                                   0, 0, 0, 0x40,
                                   0, 0, 0x40, 0x40]))
    }
    
    func testEncodeArrayDouble() {
        struct TestStruct: Codable {
            let a: [Double]
        }
        let value = TestStruct(a: [1, 2, 3])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([3, 0, 0, 0,
                                   0, 0, 0, 0,
                                   0, 0, 0, 0, 0, 0, 0xf0, 0x3f,
                                   0, 0, 0, 0, 0, 0, 0, 0x40,
                                   0, 0, 0, 0, 0, 0, 8, 0x40]))
    }
}
