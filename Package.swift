// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CDRCodable",
    products: [
        .library(
            name: "CDRCodable",
            targets: ["CDRCodable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CDRCodable",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CDRCodableTests",
            dependencies: ["CDRCodable"],
            path: "Tests"
        ),
    ]
)
