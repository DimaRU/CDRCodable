extension FixedWidthInteger {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self, Array.init)
    }
}
