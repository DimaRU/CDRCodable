/////
////  RosCommon.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

struct RosTimeStamp: Codable, Equatable {
    let sec: Int32
    let nanosec: UInt32
}

struct RosHeader: Codable, Equatable {
    let stamp: RosTimeStamp
    let frameId: String
}
