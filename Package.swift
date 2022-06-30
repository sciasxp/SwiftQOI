// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftQOI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftQOI",
            targets: ["SwiftQOI"]),
    ],
    targets: [
        .target(
            name: "SwiftQOI",
            dependencies: []),
        .testTarget(
            name: "SwiftQOITests",
            dependencies: ["SwiftQOI"],
            resources: [.process("Assets")])
    ]
)
