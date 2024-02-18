// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "CDRCodable",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "CDRCodable", targets: ["CDRCodable"]),
        .plugin(name: "Msg2swiftCommand", targets: ["Msg2swiftCommand"]),
    ],
    dependencies: [
        .package(url: "https://github.com/DimaRU/Msg2swift.git", branch: "master")
    ],
    targets: [
        .target(
            name: "CDRCodable"),
        .testTarget(
            name: "CDRCodableTests",
            dependencies: ["CDRCodable"]
        ),
        .plugin(
            name: "Msg2swiftCommand",
            capability: .command(
                intent: .custom(verb: "msg2swift", description: "Generate Swift model code from ROS message file."),
                permissions: [.writeToPackageDirectory(reason: "Add generated Swift code")]
            ),
            dependencies: [
                .product(name: "msg2swift", package: "Msg2swift"),
            ]
        ),
    ]
)
