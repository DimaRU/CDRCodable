import XCTest
@testable import CDRCodable

class CDRCodablePerformanceTests: XCTestCase {

    struct ImageData: Codable {
        let image: Data
        let key: String
        let stamp: UInt64
    }

    func testDataDecodeEncode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)

        let encoder = CDREncoder()
        let cdrData = try! encoder.encode(imageData)
        XCTAssertEqual(cdrData.count, 40984)

        let decoder = CDRDecoder()
        let decodedImage = try! decoder.decode(ImageData.self, from: cdrData)
        XCTAssertEqual(decodedImage.key, "Key")
    }
    
    func testPerformanceDataDecode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)
        
        let encoder = CDREncoder()
        let cdrData = try! encoder.encode(imageData)

        let decoder = CDRDecoder()
        
        self.measure {
            for _ in 1...100 {
                let decodedImage = try! decoder.decode(ImageData.self, from: cdrData)
                XCTAssertEqual(decodedImage.key, "Key")
            }
        }
    }

    func testPerformanceDataEncode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)
        
        let encoder = CDREncoder()

        self.measure {
            for _ in 1...100 {
                let cdrData = try! encoder.encode(imageData)
                XCTAssertEqual(cdrData.count, 40984)
            }
        }
    }

}
