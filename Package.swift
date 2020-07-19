// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LingueeOnAlfred",
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
    ],
    targets: [
        .target(
            name: "LingueeOnAlfred",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "LingueeOnAlfredTests",
            dependencies: ["LingueeOnAlfred"]),
    ]
)
