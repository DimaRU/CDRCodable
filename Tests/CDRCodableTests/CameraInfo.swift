/////
////  CameraInfo.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import CDRCodable
extension InlineArray: @retroactive Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        !(0 ..< Self.count).contains { lhs[$0] != rhs[$0] }
    }
}

extension InlineArray: @retroactive Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        (0 ..< Self.count).forEach {
            hasher.combine(self[$0])
        }
    }
}

extension InlineArray: @retroactive CustomStringConvertible {
    public var description: String {
        "\((0 ..< Self.count).map { self[$0] })"
    }
}

struct CameraInfo: Codable, Equatable {
    struct RegionOfInterest: Codable, Equatable {
        let x_offset: UInt32  // (0 if the ROI includes the left edge of the image)
        let y_offset: UInt32  // (0 if the ROI includes the top edge of the image)
        let height: UInt32    //
        let width: UInt32     //
        let do_rectify: Bool
    }

    let header: RosHeader
    let height: UInt32
    let width: UInt32
    let distortion_model: String
    let d: [Double]
    
    let k: [9 of Double]
    let r: [9 of Double]
    let p: [12 of Double]
    
    let binningX: UInt32
    let binningY: UInt32
    let roi: RegionOfInterest
}
