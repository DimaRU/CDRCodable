import XCTest
@testable import CDRCodable

class CDRCodableEncodingTests: XCTestCase {
    var encoder: CDREncoder!
    
    override func setUp() {
        self.encoder = CDREncoder()
    }

    func testEncodeFalse() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data([0, 0, 0, 0]))
    }
    
    func testEncodeTrue() {
        let value = try! encoder.encode(true)
        XCTAssertEqual(value, Data([1, 0, 0, 0]))
    }
    
    func testEncodeInt32() {
        let value = try! encoder.encode(42 as Int32)
        XCTAssertEqual(value, Data([0x2A, 0, 0, 0]))
    }
    
    func testEncodeUInt32() {
        let value = try! encoder.encode(128 as UInt32)
        XCTAssertEqual(value, Data([0x80, 0, 0, 0]))
    }
    
    func testEncodeFloat() {
        let value = try! encoder.encode(3.14 as Float)
        XCTAssertEqual(value, Data([0xC3, 0xF5, 0x48, 0x40]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159 as Double)
        XCTAssertEqual(value, Data([0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40]))
    }
    
    func testEncodeString() {
        let value = try! encoder.encode("hello")
        XCTAssertEqual(value, Data([6, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0]))
    }
    
    func testEncodeArray() {
        let array: [Int16] = [1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0, 1, 0, 2, 0, 3, 0, 0, 0]))
    }
    
    func testEncodeData() {
        let data = "hello".data(using: .utf8)
        let value = try! encoder.encode(data)
        XCTAssertEqual(value, Data([5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0]))
    }
    
    static var allTests = [
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeInt32", testEncodeInt32),
        ("testEncodeUInt32", testEncodeUInt32),
        ("testEncodeFloat", testEncodeFloat),
        ("testEncodeDouble", testEncodeDouble),
        ("testEncodeArray", testEncodeArray),
    ]
}
