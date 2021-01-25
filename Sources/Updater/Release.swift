import Foundation

public struct Release {
  /// The version of the release.
  public let version: Version
  /// The URL to fetch the new workflow.
  public let workflowURL: URL
  /// The release page URL.
  public let releaseURL: URL
  /// When the release has been published.
  public let releaseDate: Date

  public init(version: Version, workflowURL: URL, releaseURL: URL, releaseDate: Date) {
    self.version = version
    self.workflowURL = workflowURL
    self.releaseURL = releaseURL
    self.releaseDate = releaseDate
  }
}

extension Release: Codable {}
extension Release: Equatable {}
