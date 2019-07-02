// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ConfigParser",
    products: [
        .library(
            name: "ConfigParser",
            targets: ["ConfigParser"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Ponyboy47/TrailBlazer.git", from: "0.16.0"),
    ],
    targets: [
        .target(
            name: "ConfigParser",
            dependencies: ["TrailBlazer"]
        ),
        .testTarget(
            name: "ConfigParserTests",
            dependencies: ["ConfigParser"]
        ),
    ]
)
