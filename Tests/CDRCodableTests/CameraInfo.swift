/////
////  CameraInfo.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

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
    
    let k: [Double]     // 9
    let r: [Double]     // 9
    let p: [Double]     // 12
    
    let binningX: UInt32
    let binningY: UInt32
    let roi: RegionOfInterest

    // Fixed size array discriminators
    enum CodingKeys: Int, CodingKey {
        case header = 0
        case height = 1
        case width = 2
        case distortion_model = 3
        case d = 4
        case k = 0x90005
        case r = 0x90006
        case p = 0xc0007
        case binningX = 8
        case binningY = 9
        case roi = 10
    }
}
