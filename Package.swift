// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConsoleProgressKit",
    products: [
        .library(
            name: "ConsoleProgressKit",
            targets: ["ConsoleProgressKit"]),
    ],
    targets: [
        .target(
            name: "ConsoleProgressKit"),

    ]
)
