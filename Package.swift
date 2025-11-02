// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSONParser",
    products: [
        .library(name: "JSONParser", targets: ["JSONParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Vaida12345/Essentials.git", from: "1.1.9"),
        .package(url: "https://github.com/Vaida12345/DetailedDescription.git", from: "2.0.3"),
    ],
    targets: [
        .target(name: "JSONParser", dependencies: ["Essentials", "DetailedDescription"]),
        .testTarget(name: "JSONParserTests", dependencies: ["JSONParser"]),
    ]
)
