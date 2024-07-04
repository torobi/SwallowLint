// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swallowlint",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "swallowlint",
            targets: ["swallowlint"]
        ),
        .plugin(
            name: "SwallowLintBuildToolPlugin",
            targets: ["SwallowLintBuildToolPlugin"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "510.0.0"
        ),
        .package(
            url: "https://github.com/jpsim/SourceKitten",
            from: "0.35.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.1"
        ),
    ],
    targets: [
        .executableTarget(
            name: "swallowlint",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
        ),
        .plugin(
            name: "SwallowLintBuildToolPlugin",
            capability: .buildTool(),
            dependencies: [
                "swallowlint"
            ]
        )
    ]
)
