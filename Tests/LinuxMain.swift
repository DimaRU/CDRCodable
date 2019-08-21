import XCTest
@testable import CDRCodableTests

XCTMain([
    testCase(CDRCodableDecodingTests.allTests),
    testCase(CDRCodableEncodingTests.allTests),
    testCase(CDRCodableRoundTripTests.allTests),
])
