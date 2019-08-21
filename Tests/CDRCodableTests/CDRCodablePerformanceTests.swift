import XCTest
@testable import CDRCodable

class CDRCodablePerformanceTests: XCTestCase {
    var encoder: CDREncoder!
    var decoder: CDRDecoder!
    
    override func setUp() {
        self.encoder = CDREncoder()
        self.decoder = CDRDecoder()
    }
    
    func testPerformance() {
        let count = 100
        let values = [Airport](repeating: .example, count: count)
        
        self.measure {
            let encoded = try! encoder.encode(values)
            let decoded = try! decoder.decode([Airport].self, from: encoded)
            XCTAssertEqual(decoded.count, count)
        }
    }
}
