//
//  TempTests.swift
//  CDRCodableTests
//
//  Created by Dmitriy Borovikov on 19/08/2019.
//

import XCTest
@testable import CDRCodable

class TempTests: XCTestCase {
    let testDump: [UInt8] =
        [ 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0xdb, 0xf9, 0x7e, 0x6a,
          0xbc, 0x74, 0x37, 0x40, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00,
          0x6d, 0x73, 0x35, 0x38, 0x33, 0x37, 0x00, 0x00 ]
    
    var decoder: CDRDecoder!

    override func setUp() {
        decoder = CDRDecoder()
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
        let test = try! decoder.decode(CommonTemp.self, from: data)
        XCTAssertEqual(test, example)
    }
    
    func testTempNested() {
        struct OrovTime: Codable, Equatable {
            let sec: Int32
            let nanosec: UInt32
        }
        
        struct OrovHeader: Codable, Equatable {
            let stamp: OrovTime
            let frameId: String
        }
        
        struct OrovTemperature_: Codable, Equatable {
            let header: OrovHeader
            let temperature: Double
            let variance: Double
        }
        
        struct OrovTemperature: Codable, Equatable {
            let temperature_: OrovTemperature_
            let id: String

            var key: String { return id }
        }
        
        let example = OrovTemperature(temperature_: OrovTemperature_(header: OrovHeader(stamp: OrovTime(sec: 0,
                                                                                                        nanosec: 0),
                                                                                        frameId: ""),
                                                                     temperature: 23.456,
                                                                     variance: 0.0),
                                      id: "ms5837")
        
        let data = Data(testDump)
        let value = try! decoder.decode(OrovTemperature.self, from: data)
        XCTAssertEqual(value, example)

    
        let encoder = CDREncoder()
        let dataBack = try! encoder.encode(value)
        XCTAssertEqual(dataBack, data)
    }

}
