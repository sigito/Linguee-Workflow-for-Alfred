import Foundation

@testable import Updater

extension LatestRelease {
  /// A sample response stored in the `github-latest-release-0.4.0.json`.
  static var sampleData: Data {
    // TODO(SR-12912): remove once the bug is fixed, and replace with:
    // Bundle.module.url(forResource: "github-latest-release-0.4.0", withExtension: "json")!
    let url = URL(fileURLWithPath: #file, isDirectory: false)
      .deletingLastPathComponent()
      .appendingPathComponent("Resources/github-latest-release-0.4.0.json")
    return try! Data(contentsOf: url)
  }

  /// The latest release stored in the `sampleData`.
  static var sampleRelease: LatestRelease {
    let date = DateComponents(
      calendar: .current, timeZone: TimeZone(abbreviation: "UTC")!, year: 2020, month: 08, day: 23,
      hour: 12, minute: 32, second: 10
    ).date!
    let htmlURL = URL(
      string: "https://github.com/sigito/Linguee-Workflow-for-Alfred/releases/tag/0.4.0")!
    let asset = Asset(
      name: "Linguee.Search.alfredworkflow",
      browserDownloadURL: URL(
        string:
          "https://github.com/sigito/Linguee-Workflow-for-Alfred/releases/download/0.4.0/Linguee.Search.alfredworkflow"
      )!)
    return LatestRelease(
      tagName: "0.4.0",
      htmlURL: htmlURL,
      publishedAt: date,
      assets: [asset])
  }
}
