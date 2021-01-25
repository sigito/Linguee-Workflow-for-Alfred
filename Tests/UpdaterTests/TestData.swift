import Foundation

@testable import Updater

extension Release {
  init(version: Version) {
    self.init(
      version: version,
      workflowURL: URL(string: "https://example.com/release/worflow")!,
      releaseURL: URL(string: "https://example.com/release/")!,
      releaseDate: Date())
  }
}

extension Asset {
  static var assetWithWorkflow: Self {
    .init(
      name: "Linguee.Search.alfredworkflow",
      browserDownloadURL: URL(string: "https://example.com/release/worflow")!)
  }
}

extension LatestRelease {
  init(
    tagName: String,
    workflow: Asset? = .assetWithWorkflow
  ) {
    let assets = [workflow].compactMap { $0 }
    self.init(
      tagName: tagName,
      htmlURL: URL(string: "https://example.com/release/")!,
      publishedAt: Date(),
      assets: assets)
  }
}
