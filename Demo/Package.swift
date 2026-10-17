// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConsoleProgressKitDemo",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "progress-demo",
            targets: ["ProgressDemo"]
        ),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/nikolainobadi/SwiftPickerKit.git", branch: "handle-kill-signal-better"),
        .package(url: "https://github.com/nikolainobadi/NnArgumentParser.git", branch: "async-workflow"),
        .package(url: "https://github.com/nikolainobadi/NnShellKit.git", branch: "handle-kill-signal")
    ],
    targets: [
        .executableTarget(
            name: "ProgressDemo",
            dependencies: [
                .product(name: "ConsoleProgressKit", package: "ConsoleProgressKit"),
                .product(name: "SwiftPickerKit", package: "SwiftPickerKit"),
                .product(name: "NnArgumentParser", package: "NnArgumentParser"),
                .product(name: "NnShellKit", package: "NnShellKit")
            ]
        ),
    ]
)
