// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Sqids",
    products: [
        .library(name: "Sqids", targets: ["Sqids"]),
    ],
    targets: [
        .target(name: "Sqids"),
        .testTarget(name: "SqidsTests", dependencies: ["Sqids"]),
    ]
)
