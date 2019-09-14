import XCTest
@testable import CDRCodable

class CDRCodableRoundTripTests: XCTestCase {
    let testDump: [UInt8] =
        [ 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0xdb, 0xf9, 0x7e, 0x6a,
          0xbc, 0x74, 0x37, 0x40, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00,
          0x6d, 0x73, 0x35, 0x38, 0x33, 0x37, 0x00, 0x00 ]
    
    var decoder: CDRDecoder!
    var encoder: CDREncoder!

    override func setUp() {
        decoder = CDRDecoder()
        encoder = CDREncoder()
    }

    func testTemp() {
        struct CommonTemp: Codable, Equatable {
            let sec: Int32
            let nanosec: UInt32
            let frameId: String
            let temperature: Double
            let variance: Double
            let id: String
        }
        let example = CommonTemp(sec: 0,
                                 nanosec: 0,
                                 frameId: "",
                                 temperature: 23.456,
                                 variance: 0.0,
                                 id: "ms5837")

        let data = Data(testDump)
        let value = try! decoder.decode(CommonTemp.self, from: data)
        XCTAssertEqual(value, example)

        let dataBack = try! encoder.encode(value)
        XCTAssertEqual(dataBack, data)
    }
    
    func testTempNested() {
        struct RovTime: Codable, Equatable {
            let sec: Int32
            let nanosec: UInt32
        }
        
        struct RovHeader: Codable, Equatable {
            let stamp: RovTime
            let frameId: String
        }
        
        struct RovTemperature_: Codable, Equatable {
            let header: RovHeader
            let temperature: Double
            let variance: Double
        }
        
        struct RovTemperature: Codable, Equatable {
            let temperature: RovTemperature_
            let id: String

            var key: String { return id }
        }
        
        let example = RovTemperature(temperature: RovTemperature_(header: RovHeader(stamp: RovTime(sec: 0,
                                                                                                   nanosec: 0),
                                                                                    frameId: ""),
                                                                  temperature: 23.456,
                                                                  variance: 0.0),
                                     id: "ms5837")
        
        let data = Data(testDump)
        let value = try! decoder.decode(RovTemperature.self, from: data)
        XCTAssertEqual(value, example)

        let dataBack = try! encoder.encode(value)
        XCTAssertEqual(dataBack, data)
    }

}
