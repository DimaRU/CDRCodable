import Foundation

/**
 An object that decodes instances of a data type from CDRCodable objects.
 */
final public class CDRDecoder {
    public init() {}
    
    /**
     A dictionary you use to customize the decoding process
     by providing contextual information.
     */
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /**
     Returns a value of the type you specify,
     decoded from a CDRCodable object.
     
     - Parameters:
        - type: The type of the value to decode
                from the supplied CDRCodable object.
        - data: The CDRCodable object to decode.
     - Throws: `DecodingError.dataCorrupted(_:)`
               if the data is not valid CDRCodable.
     */
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let decoder = _CDRDecoder(data: _CDRDecoder.DataBlock(data: data))
        decoder.userInfo = self.userInfo
        
        return try T(from: decoder)
    }
}

// MARK: -


final class _CDRDecoder {
    
    final class DataBlock {
        let data: Data
        var index: Data.Index
        init(data: Data) {
            self.data = data
            self.index = self.data.startIndex
        }
    }
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var container: _CDRDecodingContainer?
    var data: DataBlock
    
    init(data: DataBlock) {
        self.data = data
    }
}

extension _CDRDecoder: Decoder {
    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }
        
    func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedDecodingContainer {
        assertCanCreateContainer()
        
        let container = UnkeyedContainer(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }
    
    func singleValueContainer() -> SingleValueDecodingContainer {
        assertCanCreateContainer()
        
        let container = SingleValueContainer(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}

protocol _CDRDecodingContainer: AnyObject {
    var codingPath: [CodingKey] { get set }
    var userInfo: [CodingUserInfoKey : Any] { get }
    var data: _CDRDecoder.DataBlock { get }
}

extension _CDRDecodingContainer {
    func readByte() throws -> UInt8 {
        return try read(1).first!
    }

    func read(_ length: Int) throws -> Data {
        let nextIndex = self.data.index.advanced(by: length)
        guard nextIndex <= self.data.data.endIndex else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unexpected end of data")
            throw DecodingError.dataCorrupted(context)
        }
        defer { self.data.index = nextIndex }

        return self.data.data.subdata(in: self.data.index..<nextIndex)
    }

    func read<T>(_ type: T.Type) throws -> T where T : FixedWidthInteger {
        let aligment = MemoryLayout<T>.alignment
        let offset = self.data.index % aligment
        if offset != 0 {
            self.data.index = self.data.index.advanced(by: aligment - offset)
        }
        let stride = MemoryLayout<T>.stride
        let bytes = [UInt8](try read(stride))
        return T(bytes: bytes)
    }

}
