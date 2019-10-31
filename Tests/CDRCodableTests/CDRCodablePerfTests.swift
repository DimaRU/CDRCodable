import XCTest
@testable import CDRCodable

class CDRCodablePerfTests: XCTestCase {

    struct ImageData: Codable {
        let image: Data
        let key: String
        let stamp: UInt64
    }

    
    override func setUp() {
    }

    override func tearDown() {
    }


    func testDataDecode() {
        let testData = Data(repeating: 1, count: 40 * 1024)
        let imageData = ImageData(image: testData, key: "Key", stamp: 123456789)
        
        let encoder = CDREncoder()
        let cdrData = try! encoder.encode(imageData)
        let decoder = CDRDecoder()

        let decodedImage = try! decoder.decode(ImageData.self, from: cdrData)
        XCTAssertEqual(decodedImage.key, "Key")
    }
    
    
    func testPerformanceData() {
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

}
