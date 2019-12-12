// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ConfigParser",
    products: [
        .library(
            name: "ConfigParser",
            targets: ["ConfigParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Ponyboy47/Pathman.git", from: "0.18.0"),
    ],
    targets: [
        .target(
            name: "ConfigParser",
            dependencies: ["Pathman"]),
        .testTarget(
            name: "ConfigParserTests",
            dependencies: ["ConfigParser"]),
    ]
)
