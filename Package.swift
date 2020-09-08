// swift-tools-version:5.3

import Foundation
import PackageDescription

var mainlineBranch = "val-verde-mainline"

if let _mainlineBranch = getenv("MAINLINE_BRANCH") {
     mainlineBranch = String(cString: _mainlineBranch)
}

let package = Package(
    name: "baikonur",
    dependencies: [
        .package(url: "https://github.com/val-verde/vapor.git", .branch(mainlineBranch)),
        .package(url: "https://github.com/val-verde/swift-argument-parser.git", .branch("val-verde-mainline")),
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
