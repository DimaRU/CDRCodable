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

}
