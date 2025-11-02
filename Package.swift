// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSONParser",
    products: [
        .library(name: "JSONParser", targets: ["JSONParser"]),
    ],
    targets: [
        .target(name: "JSONParser"),
        .testTarget(name: "JSONParserTests", dependencies: ["JSONParser"]),
    ]
)
