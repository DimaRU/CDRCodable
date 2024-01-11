// swift-tools-version:5.6

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
