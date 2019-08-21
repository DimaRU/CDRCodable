import XCTest
@testable import CDRCodable

class CDRCodableRoundTripTests: XCTestCase {
    var encoder: CDREncoder!
    var decoder: CDRDecoder!
    
    override func setUp() {
        self.encoder = CDREncoder()
        self.decoder = CDRDecoder()
    }

    func testRoundTrip() {
        let value = Airport.example
        let encoded = try! encoder.encode(value)
        let decoded = try! decoder.decode(Airport.self, from: encoded)

        XCTAssertEqual(value.name, decoded.name)
        XCTAssertEqual(value.iata, decoded.iata)
        XCTAssertEqual(value.icao, decoded.icao)
        XCTAssertEqual(value.coordinates[0], decoded.coordinates[0], accuracy: 0.01)
        XCTAssertEqual(value.coordinates[1], decoded.coordinates[1], accuracy: 0.01)
        XCTAssertEqual(value.runways[0].direction, decoded.runways[0].direction)
        XCTAssertEqual(value.runways[0].distance, decoded.runways[0].distance)
        XCTAssertEqual(value.runways[0].surface, decoded.runways[0].surface)
    }

    func testRoundTripArray() {
        let count: UInt8 = 100
        var bytes: [UInt8] = [count, 0, 0, 0]
        var encoded: [Int8] = []
        for n in 1...count {
            bytes.append(n)
            encoded.append(Int8(n))
        }

        let data = Data(bytes)
        let decoded = try! decoder.decode([Int8].self, from: data)
        XCTAssertEqual(encoded, decoded)
    }
    
    static var allTests = [
        ("testRoundTrip", testRoundTrip),
        ("testRoundTripArray", testRoundTripArray),
    ]
}
