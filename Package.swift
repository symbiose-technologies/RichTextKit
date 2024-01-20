// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RichTextKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "RichTextKit",
            targets: ["RichTextKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danielsaidi/MockingKit.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/ChimeHQ/Neon.git", from: "0.5.1"),
        .package(url: "https://github.com/ChimeHQ/TextStory.git", from: "0.8.0"),
        .package(url: "https://github.com/ChimeHQ/TextFormation.git", from: "0.8.1"),
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter.git", from: "0.7.2"),
        .package(url: "https://github.com/symbiose-technologies/tree-sitter-markdown.git", branch: "symbiose-main"),
        .package(url: "https://github.com/apple/swift-markdown.git", branch:"main"),
        .package(url: "https://github.com/symbiose-technologies/Atributika.git", branch: "symbiose")
    ],
    targets: [
        .target(
            name: "RichTextKit",
            dependencies: [
                .product(name: "Neon", package: "Neon"),
                .product(name: "TextFormation", package: "TextFormation"),
                .product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
                .product(name: "TreeSitterDocument", package: "SwiftTreeSitter"),
                .product(name: "TextStory", package: "TextStory"),
                .product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
                .product(name: "Markdown", package: "swift-markdown")
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "RichTextKitTests",
            dependencies: ["RichTextKit", "MockingKit"]),
    ]
)
