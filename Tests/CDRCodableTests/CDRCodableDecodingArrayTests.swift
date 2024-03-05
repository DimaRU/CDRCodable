/////
////  CDRCodableDecodingArrayTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodableDecodingArrayTests: XCTestCase {
    var decoder: CDRDecoder!
    
    override func setUp() {
        self.decoder = CDRDecoder()
    }
    
    func testDecodeData() {
        let data = Data([5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode(Data.self, from: data)
        XCTAssertEqual(value, "hello".data(using: .utf8))
    }
    
    func testDecodeArray8() {
        let data = Data([3, 0, 0, 0, 0xff, 2, 3, 0])
        let value = try! decoder.decode([Int8].self, from: data)
        XCTAssertEqual(value, [-1, 2, 3])
    }

    func testDecodeArray16() {
        let data = Data([3, 0, 0, 0, 0xff, 0xff, 2, 0, 3, 0, 0, 0])
        let value = try! decoder.decode([Int16].self, from: data)
        XCTAssertEqual(value, [-1, 2, 3])
    }
    
    func testDecodeArray32() {
        let data = Data([3, 0, 0, 0, 0xff, 0xff, 0xff, 0xff, 2, 0, 0, 0, 3, 0, 0, 0])
        let value = try! decoder.decode([Int32].self, from: data)
        XCTAssertEqual(value, [-1, 2, 3])
    }

    func testDecodeArray64() {
        let data = Data([3, 0, 0, 0,
                         0, 0, 0, 0,
                         0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
                         2, 0, 0, 0, 0, 0, 0, 0,
                         3, 0, 0, 0, 0, 0, 0, 0])
        let value = try! decoder.decode([Int64].self, from: data)
        XCTAssertEqual(value, [-1, 2, 3])
    }

    func testDecodeArrayFloat() {
        let data = Data([3, 0, 0, 0,
                         0, 0, 0x80, 0x3f,
                         0, 0, 0, 0x40,
                         0, 0, 0x40, 0x40])
        let value = try! decoder.decode([Float].self, from: data)
        XCTAssertEqual(value, [1, 2, 3])
    }

    func testDecodeArrayDoble() {
        let data = Data([3, 0, 0, 0,
                         0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0xf0, 0x3f,
                         0, 0, 0, 0, 0, 0, 0, 0x40,
                         0, 0, 0, 0, 0, 0, 8, 0x40])
        let value = try! decoder.decode([Double].self, from: data)
        XCTAssertEqual(value, [1, 2, 3])
    }
}
