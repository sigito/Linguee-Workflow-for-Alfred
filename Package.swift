// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LingueeOnAlfred",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(name: "LingueeOnAlfred", targets: ["LingueeOnAlfred"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
  ],
  targets: [
    .executableTarget(
      name: "LingueeOnAlfred",
      dependencies: ["LingueeSearchWorkflow"]),

    .target(
      name: "LingueeSearchWorkflow",
      dependencies: [
        "Alfred",
        "Linguee",
        "Updater",
      ]),
    .testTarget(
      name: "LingueeSearchWorkflowTests",
      dependencies: [
        "CommonTesting",
        "LingueeSearchWorkflow",
        "LingueeTestData",
      ],
      resources: [.copy("Resources/bereich-items.json")]
    ),

    .target(
      name: "Alfred",
      dependencies: []),
    .testTarget(
      name: "AlfredTests",
      dependencies: ["Alfred", "CommonTesting"]),

    .target(
      name: "Linguee",
      dependencies: ["Common", "SwiftSoup"]),
    .testTarget(
      name: "LingueeTests",
      dependencies: [
        "Linguee",
        "CommonTesting",
        "LingueeTestData",
      ],
      exclude: ["TestData"]
    ),
    .target(
      name: "LingueeTestData",
      dependencies: ["Linguee"],
      path: "Tests/LingueeTests/TestData",
      resources: [
        .copy("Resources/bereich-ende-translation-response.html"),
        .copy("Resources/hello-enjp-translation-response.html"),
      ]),
    .target(
      name: "Updater",
      dependencies: [
        "Common",
        .product(name: "Logging", package: "swift-log"),
      ]),
    .testTarget(
      name: "UpdaterTests",
      dependencies: ["Updater", "CommonTesting"],
      resources: [.copy("Resources/github-latest-release-0.4.0.json")]
    ),

    .target(name: "Common"),
    .target(
      name: "CommonTesting",
      dependencies: ["Common"],
      path: "Tests/CommonTesting"),
  ]
)
