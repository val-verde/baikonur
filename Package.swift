// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "baikonur",
    dependencies: [
        .package(url: "https://github.com/val-verde/vapor.git", .branch("dutch-master")),
        .package(url: "https://github.com/val-verde/swift-argument-parser.git", .branch("dutch-master")),
    ],
    targets: [
        .target(name: "baikonur", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "baikonurTests", dependencies: [
            .target(name: "baikonur"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
