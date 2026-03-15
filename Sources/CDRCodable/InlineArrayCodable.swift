/////
////  InlineArrayCodable.swift
///   Copyright © 2026 Dmitriy Borovikov. All rights reserved.
//

import Foundation

extension InlineArray: @retroactive Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        for index in indices {
            try container.encode(self[index])
        }
    }
}

extension InlineArray: @retroactive Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try .init { _ in try container.decode(Element.self) }
    }
}
