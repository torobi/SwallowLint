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
        ),
        .plugin(
            name: "SwallowLintCommandPlugin",
            targets: ["SwallowLintCommandPlugin"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "600.0.1"
        ),
        .package(
            url: "https://github.com/jpsim/SourceKitten",
            from: "0.35.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.1"
        ),
        .package(
            url: "https://github.com/Quick/Quick.git",
            from: "7.6.1"
        ),
        .package(
            url: "https://github.com/Quick/Nimble.git",
            from: "13.3.0"
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
        .testTarget(
            name: "SwallowLintTest",
            dependencies: [
                "swallowlint",
                "Nimble",
                "Quick"
            ]
        ),
        .plugin(
            name: "SwallowLintBuildToolPlugin",
            capability: .buildTool(),
            dependencies: [
                "swallowlint"
            ]
        ),
        .plugin(
            name: "SwallowLintCommandPlugin",
            capability: .command(
                intent: .custom(
                    verb: "swallowlint",
                    description: "simple swift linter."
                ),
                permissions: []
            ),
            dependencies: [
                "swallowlint"
            ]
        )
    ]
)
