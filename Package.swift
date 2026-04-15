// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "WWDebugOverlay",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "WWDebugOverlay",
            targets: ["WWDebugOverlay"]
        )
    ],
    targets: [
        .target(
            name: "WWDebugOverlay"
        ),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
