import Foundation
import Logging

fileprivate let user = "sigito"
fileprivate let repository = "Linguee-Workflow-for-Alfred"

public enum UpdateMonitorError: Error {
  case workflowNotFound(LatestRelease)
  case generic(Error)
}

public class UpdateMonitor {

  private let logger = Logger(
    label: "\(UpdateMonitor.self)", factory: StreamLogHandler.standardError(label:))
  /// The current version of the workflow.
  public let currentVersion: Version
  /// The number of seconds between GitHub API requests.
  private let requestInterval: TimeInterval
  /// The number of seconds the previously fetchead release is cached.
  private let cacheExpirationInterval: TimeInterval
  private let localStore: LocalStore
  private let gitHubAPI: GitHubAPI

  /// Paramaters:
  ///   - cacheExpirationInterval: the time interval to keep the available new release information
  ///     in a cache, instead of requesting a new one.
  public init(
    currentVersion: Version = .unknown,
    requestInterval: TimeInterval,
    cacheExpirationInterval: TimeInterval,
    localStore: LocalStore,
    gitHubAPI: GitHubAPI
  ) {
    self.currentVersion = currentVersion
    self.requestInterval = requestInterval
    self.cacheExpirationInterval = cacheExpirationInterval
    self.localStore = localStore
    self.gitHubAPI = gitHubAPI
  }

  public func availableUpdate() async throws -> Release? {
    if let release = self.previoslyFetchedRelease(freshness: self.cacheExpirationInterval) {
      self.logger.debug("Returning cached release: \(release)")
      return release
    }
    guard self.moreThan(self.requestInterval, since: try? self.localStore.checkAttemptTimestamp())
    else {
      self.logger.debug(
        "Previous GitHub request was sent less than \(self.requestInterval) seconds ago. Skipping."
      )
      return nil
    }
    // Store the attempt immediately, so the very next workflow execution would not send a new
    // request.
    try? self.localStore.save(checkAttemptTimestamp: Date().timeIntervalSince1970)

    let latestRelease = try await self.gitHubAPI.getLatestRelease(
      user: user, repository: repository)
    let workflowRelease = try self.releaseWithWorkflow(latestRelease)
    return self.processGitHubRelease(workflowRelease)
  }

  // MARK: - Private

  private func releaseWithWorkflow(_ latestRelease: LatestRelease) throws -> Release {
    guard
      let workflowAsset = latestRelease.assets.first(where: { $0.name.hasSuffix("alfredworkflow") })
    else {
      throw UpdateMonitorError.workflowNotFound(latestRelease)
    }
    let version = Version(latestRelease.tagName) ?? .unknown
    return Release(
      version: version,
      workflowURL: workflowAsset.browserDownloadURL,
      releaseURL: latestRelease.htmlURL,
      releaseDate: latestRelease.publishedAt)
  }

  /// Returns the previosly fetched release, if it is not older than `freshness` interval, and its
  /// version is ahead of `currentVersion`. Otherwise, nil.
  /// - Parameter freshness: The number of seconds after which the release is considered obsolete.
  private func previoslyFetchedRelease(freshness: TimeInterval) -> Release? {
    let release: Release
    let releaseFetchTimestamp: TimeInterval
    do {
      guard let latestRelease = try localStore.latestRelease() else {
        return nil
      }
      release = latestRelease.release
      releaseFetchTimestamp = latestRelease.timestamp
    } catch {
      logger.error("Failed to load previosly fetched release: \(error)")
      return nil
    }

    guard !moreThan(freshness, since: releaseFetchTimestamp) else {
      logger.debug(
        "Previosly fetched release is more than a week old. Fetched at \(releaseFetchTimestamp).")
      return nil
    }
    guard isNewRelease(release: release) else {
      logger.debug(
        "Previosly fetched released is not newer than the currently running version: \(release.version) < \(String(describing: currentVersion))"
      )
      return nil
    }
    return release
  }

  /// Whether the `release` is newer than the `currentVersion`.
  private func isNewRelease(release: Release) -> Bool {
    return release.version > currentVersion
  }

  /// Whether `difference` has passed since `timestamp`.
  private func moreThan(_ difference: TimeInterval, since timestamp: TimeInterval?) -> Bool {
    guard let timestamp = timestamp else {
      return true
    }
    let timeSinceFetch = Date().timeIntervalSince1970 - timestamp
    return timeSinceFetch >= difference
  }

  /// Stores and filters the GitHub `release` if available.
  /// An instance of release is returned only if it is an update candidate.
  private func processGitHubRelease(_ release: Release?) -> Release? {
    guard let release = release else {
      self.logger.debug("No releases found on GitHub!")
      return nil
    }
    do {
      // Store the release even if it is not matching, to prevent a repeated call.
      try self.localStore.save(latestRelease: release)
    } catch {
      self.logger.error("Failed to save a release from GitHub: \(error)")
    }
    guard self.isNewRelease(release: release) else {
      self.logger.debug(
        "GitHub latest released is not newer than the currently running version: \(release.version) < \(String(describing: currentVersion))"
      )
      return nil
    }
    return release
  }
}
