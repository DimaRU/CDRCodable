/////
////  CDRCodableDecodingErrorTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodableDecodingErrorTests: XCTestCase {
    var decoder: CDRDecoder!
    
    override func setUp() {
        self.decoder = CDRDecoder()
    }
    
    func testDecodeInt32EOD() {
        let data = Data([0, 0, 0])
        XCTAssertThrowsError(try decoder.decode(Int32.self, from: data), "Unexpected end of data") {
            guard case DecodingError.dataCorrupted = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    func testDecodeStringCountEOD() {
        let data = Data([0, 0, 0])
        XCTAssertThrowsError(try decoder.decode(String.self, from: data), "Unexpected end of data") {
            guard case DecodingError.dataCorrupted = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    func testDecodeStringEOD() {
        let data = Data([2, 0, 0, 0, 0x55])
        XCTAssertThrowsError(try decoder.decode(String.self, from: data), "Unexpected end of data") {
            guard case DecodingError.dataCorrupted = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    func testDecodeArrayEOD() {
        let data = Data([1, 0, 0, 0,
                         0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0])
        XCTAssertThrowsError(try decoder.decode([Int64].self, from: data), "Unexpected end of data") {
            guard case DecodingError.dataCorrupted = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    func testDecodeArrayStructEOD() {
        let data = Data([1, 0, 0, 0,
                         0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0])
        struct TestStruct: Decodable {
            let a: [Int64]
        }
        XCTAssertThrowsError(try decoder.decode(TestStruct.self, from: data), "Unexpected end of data") {
            guard case DecodingError.dataCorrupted = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    func testDecodeFixedArrayEOD() {
        let data = Data([0,  0, 0, 0,
                         0, 0, 0])
        struct TestStruct: Decodable {
            let b: UInt8
            let a: [Int32]
            enum CodingKeys: Int, CodingKey {
                case b = 0
                case a = 0x10001
            }
        }
        XCTAssertThrowsError(try decoder.decode(TestStruct.self, from: data), "Unexpected end of data") {
            guard case DecodingError.dataCorrupted = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    func testDecodeFixedArrayWrongDef() {
        let data = Data([0,  0, 0, 0,
                         0, 0, 0, 0])
        struct TestStruct: Decodable {
            let a: [Data]
            enum CodingKeys: Int, CodingKey {
                case a = 0x10001
            }
        }
        XCTAssertThrowsError(try decoder.decode(TestStruct.self, from: data), "Unexpected end of data") {
            guard case DecodingError.typeMismatch = $0 else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
}
