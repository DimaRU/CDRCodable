/////
////  SingleValueDecodingContainer.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

extension _CDRDecoder {
    struct SingleValueContainer {
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        let dataStore: DataStore

        init(dataStore: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = dataStore
            self.dataStore.codingPath = codingPath
        }
    }
}

extension _CDRDecoder.SingleValueContainer: SingleValueDecodingContainer {    
    func decodeNil() -> Bool {
        true
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try dataStore.read(UInt8.self) != 0
    }
    
    func decode(_ type: String.Type) throws -> String {
        try dataStore.readString()
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Numeric & Decodable {
        try dataStore.read(T.self)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case is Data.Type:
            return try dataStore.readData() as! T
        default:
            let decoder = _CDRDecoder(dataStore: dataStore, userInfo: userInfo)
            return try T(from: decoder)
        }
    }
}

extension _CDRDecoder.SingleValueContainer: _CDRDecodingContainer {}
