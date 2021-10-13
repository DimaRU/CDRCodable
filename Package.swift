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
    targets: [
        .target(
            name: "CDRCodable"),
        .testTarget(
            name: "CDRCodableTests",
            dependencies: ["CDRCodable"]
        ),
    ]
)
