/////
////  CDRCodableEncodingArrayTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodableEncodingArrayTests: XCTestCase {
    var encoder: CDREncoder!
    
    override func setUp() {
        self.encoder = CDREncoder()
    }

    func testEncodeData() {
        let data = "hello".data(using: .utf8)
        let value = try! encoder.encode(data)
        XCTAssertEqual(value, Data([5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0]))
    }
    
    func testEncodeArray8() {
        let array: [Int8] = [-1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0, 0xff, 2, 3, 0]))
    }

    func testEncodeArray16() {
        let array: [Int16] = [-1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0, 0xff, 0xff, 2, 0, 3, 0, 0, 0]))
    }
    
    func testEncodeArray32() {
        let array: [Int32] = [-1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0, 0xff, 0xff, 0xff, 0xff, 2, 0, 0, 0, 3, 0, 0, 0]))
    }

    func testEncodeArray64() {
        let array: [Int64] = [-1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0,
                                    0, 0, 0, 0,
                                    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                                    2, 0, 0, 0, 0, 0, 0, 0,
                                    3, 0, 0, 0, 0, 0, 0, 0]))
    }

    func testEncodeArrayFloat() {
        let array: [Float] = [1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0,
                                    0, 0, 0x80, 0x3f,
                                    0, 0, 0, 0x40,
                                    0, 0, 0x40, 0x40]))
    }

    func testEncodeArrayDouble() {
        let array: [Double] = [1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0,
                                    0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0xf0, 0x3f,
                                    0, 0, 0, 0, 0, 0, 0, 0x40,
                                    0, 0, 0, 0, 0, 0, 8, 0x40]))
    }
}
