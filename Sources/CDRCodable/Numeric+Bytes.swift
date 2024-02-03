/////
////  Numeric+Bytes.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

extension Numeric {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }
}
