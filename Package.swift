// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "baikonur",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.29.1"),
    ],
    targets: [
        .target(name: "baikonur", dependencies: [
            .product(name: "Vapor", package: "vapor"),
        ]),
        .testTarget(
            name: "baikonurTests",
            dependencies: ["baikonur"]),
    ]
)
