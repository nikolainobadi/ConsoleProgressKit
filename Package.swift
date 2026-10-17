// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConsoleProgressKit",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "ConsoleProgressKit",
            targets: ["ConsoleProgressKit"]),
    ],
    targets: [
        .target(
            name: "ConsoleProgressKit",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault")
            ]
        ),
        .testTarget(
            name: "ConsoleProgressKitTests",
            dependencies: [
                "ConsoleProgressKit"
            ]
        ),
    ]
)
