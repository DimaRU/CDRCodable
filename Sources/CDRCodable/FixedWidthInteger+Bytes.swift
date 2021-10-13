extension FixedWidthInteger {
    init(bytes: [UInt8]) {
        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }.littleEndian
    }

    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }
}
