/////
////  CDRCodablePerformanceTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodablePerformanceTests: XCTestCase {

    struct ImageData: Codable {
        let image: Data
        let key: String
        let stamp: UInt64
    }
    let encoder = CDREncoder()
    let decoder = CDRDecoder()
    
    func testDataDecodeEncode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)

        let cdrData = try! encoder.encode(imageData)
        XCTAssertEqual(cdrData.count, 40984)

        let decodedImage = try! decoder.decode(ImageData.self, from: cdrData)
        XCTAssertEqual(decodedImage.key, "Key")
    }
    
    func testPerformanceDataDecode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)
        
        let cdrData = try! encoder.encode(imageData)

        self.measure {
            for _ in 1...1000 {
                let decodedImage = try! decoder.decode(ImageData.self, from: cdrData)
                XCTAssertEqual(decodedImage.key, "Key")
            }
        }
    }

    func testPerformanceDataEncode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)
        
        self.measure {
            for _ in 1...1000 {
                let cdrData = try! encoder.encode(imageData)
                XCTAssertEqual(cdrData.count, 40984)
            }
        }
    }
    
    func testPerformanceUnkeyedArrayEncode() {
        let testArray = [Int16].init(repeating: 55, count: 40 * 1024)

        self.measure {
            for _ in 1...100 {
                let cdrData = try! encoder.encode(testArray)
                XCTAssertEqual(cdrData.count, 81924)
            }
        }
    }

    func testPerformanceUnkeyedArrayDecode() {
        let testArray = [Int16].init(repeating: 55, count: 40 * 1024)
        let cdrData = try! encoder.encode(testArray)

        self.measure {
            for _ in 1...100 {
                let testArray1 = try! decoder.decode([Int16].self, from: cdrData)
                XCTAssertEqual(testArray1[0], 55)
            }
        }
    }

    func testPerformanceKeyedArrayEncode() {
        struct TestStruct: Codable {
            let a: [Int16]
        }
        let testStruct = TestStruct(a: .init(repeating: 55, count: 40 * 1024))

        self.measure {
            for _ in 1...100 {
                let cdrData = try! encoder.encode(testStruct)
                XCTAssertEqual(cdrData.count, 81924)
            }
        }
    }

    func testPerformanceKeyedArrayDecode() {
        struct TestStruct: Codable {
            let a: [Int16]
        }
        let testStruct = TestStruct(a: .init(repeating: 55, count: 40 * 1024))
        let cdrData = try! encoder.encode(testStruct)
        
        self.measure {
            for _ in 1...100 {
                let testStruct1 = try! decoder.decode(TestStruct.self, from: cdrData)
                XCTAssertEqual(testStruct1.a[0], 55)
            }
        }
    }
    
    func testPerformanceArrayOfStructEncode() {
        struct TestStruct: Codable {
            struct Internal: Codable {
                let x: Int16
                let y: Int16
            }
            let a: [Internal]
        }
        let testStruct = TestStruct(a: .init(repeating: .init(x: 1, y: 2), count: 1024))

        self.measure {
            for _ in 1...10 {
                let cdrData = try! encoder.encode(testStruct)
                XCTAssertEqual(cdrData.count, 4100)
            }
        }
    }

    func testPerformanceArrayOfStructDecode() {
        struct TestStruct: Codable {
            struct Internal: Codable {
                let x: Int16
                let y: Int16
            }
            let a: [Internal]
        }
        let testStruct = TestStruct(a: .init(repeating: .init(x: 1, y: 2), count: 1024))
        let cdrData = try! encoder.encode(testStruct)
        
        self.measure {
            for _ in 1...10 {
                let testStruct1 = try! decoder.decode(TestStruct.self, from: cdrData)
                XCTAssertEqual(testStruct1.a[0].x, 1)
            }
        }
    }

    func testPerformanceInlineArrayEncode() {
        struct TestStruct: Codable {
            let array: [1000 of Int]
        }
        let testStruct = TestStruct(array: .init(repeating: -1))

        self.measure {
            for _ in 1...100 {
                let cdrData = try! encoder.encode(testStruct)
                XCTAssertEqual(cdrData.count, 8000)
            }
        }
    }

    func testPerformanceInlineArrayDecode() {
        struct TestStruct: Codable {
            let array: [1000 of Int]
        }
        let testStruct = TestStruct(array: .init(repeating: -1))
        let cdrData = try! encoder.encode(testStruct)

        self.measure {
            for _ in 1...1000 {
                let testStruct1 = try! decoder.decode(TestStruct.self, from: cdrData)
                XCTAssertEqual(testStruct1.array[0], -1)
            }
        }
    }

}
