import XCTest
@testable import CDRCodable

class CDRCodableDecodingTests: XCTestCase {
    var decoder: CDRDecoder!
    
    override func setUp() {
        self.decoder = CDRDecoder()
    }
    
    func testDecodeFalse() {
        let data = Data([0])
        let value = try! decoder.decode(Bool.self, from: data)
        XCTAssertEqual(value, false)
    }
    
    func testDecodeTrue() {
        let data = Data([1])
        let value = try! decoder.decode(Bool.self, from: data)
        XCTAssertEqual(value, true)
    }
    
    func testDecodeInt() {
        let data = Data([0x2A, 0, 0, 0, 0, 0, 0, 0])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, 42)
    }
    
    func testDecodeUInt8() {
        let data = Data([0x80])
        let value = try! decoder.decode(UInt8.self, from: data)
        XCTAssertEqual(value, 128)
    }
    
    func testDecodeFloat() {
        let data = Data([0xC3, 0xF5, 0x48, 0x40])
        let value = try! decoder.decode(Float.self, from: data)
        XCTAssertEqual(value, 3.14)
    }
    
    func testDecodeDouble() {
        let data = Data([0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40])
        let value = try! decoder.decode(Double.self, from: data)
        XCTAssertEqual(value, 3.14159)
    }
    
    func testDecodeArray() {
        let data = Data([3, 0, 0, 0, 1, 0, 2, 0, 3, 0])
        let value = try! decoder.decode([Int16].self, from: data)
        XCTAssertEqual(value, [1, 2, 3])
    }

    func testDecodeString() {
        let data = Data([6, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0])
        let value = try! decoder.decode(String.self, from: data)
        XCTAssertEqual(value, "hello")
    }

    func testDecodeData() {
        let data = Data([5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode(Data.self, from: data)
        XCTAssertEqual(value, "hello".data(using: .utf8))
    }
}
