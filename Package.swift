// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LingueeOnAlfred",
  platforms: [
    .macOS(.v10_15),
  ],
  dependencies: [
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
  ],
  targets: [
    .target(
      name: "LingueeOnAlfred",
      dependencies: ["Linguee", "Alfred"]),

    .target(
      name: "Linguee",
      dependencies: ["SwiftSoup"]),
    .testTarget(
      name: "LingueeTests",
      dependencies: ["Linguee"]),

    .target(
      name: "Alfred",
      dependencies: []),
    .testTarget(
      name: "AlfredTests",
      dependencies: ["Alfred"]),
  ]
)
