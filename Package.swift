// swift-tools-version:5.3

import Foundation
import PackageDescription

var mainlineBranch = "val-verde-mainline"

if let _mainlineBranch = getenv("MAINLINE_BRANCH") {
     mainlineBranch = String(cString: _mainlineBranch)
}

let package = Package(
    name: "baikonur",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    dependencies: [
        .package(url: "https://github.com/val-verde/vapor.git", .branch(mainlineBranch)),
    ],
    targets: [
        .target(name: "baikonur", dependencies: [
            .product(name: "Vapor", package: "vapor"),
        ],
        linkerSettings: [
            .linkedLibrary("ArgumentParser"),
        ]),
        .testTarget(name: "baikonurTests", dependencies: [
            .target(name: "baikonur"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
