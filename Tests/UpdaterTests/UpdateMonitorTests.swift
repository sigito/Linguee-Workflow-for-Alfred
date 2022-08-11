import CommonTesting
import Foundation
import XCTest

@testable import Updater

class UpdateMonitorTest: XCTestCase {
  private var localStore: LocalStoreFake!
  private var gitHubAPI: GitHubAPIFake!
  private var monitor: UpdateMonitor!
  private var receivedAvailableUpdate: Release? = nil
  private let requestInterval: TimeInterval = 2 * 60  // 2 minute
  private let cacheExpirationInterval: TimeInterval = 7 * 24 * 60 * 60  // 1 week
  private let defaultCurrentVersion: Version = "1.0.0"

  override func setUpWithError() throws {
    localStore = LocalStoreFake()
    gitHubAPI = GitHubAPIFake()
    makeMonitor(currentVersion: defaultCurrentVersion)
  }

  /// Tests that a previously fetched release is returned, when its version is newer than current,
  /// and the release was fetched within last week.
  func testReturnsPrevioslyFetchedReleaseIfNew() async throws {
    let expectedRelease = Release(version: "1.1.0")
    let twoDaysAgo = Date.daysAgo(2)
    localStore.stubs.latestRelease = {
      VersionedRelease(release: expectedRelease, timestamp: twoDaysAgo.timeIntervalSince1970)
    }

    let release = try await monitor.availableUpdate()

    XCTAssertEqual(try XCTUnwrap(release), expectedRelease)
  }

  /// Tests that when the current version of the workflow is unknown, the cached release is
  /// returned.
  func testReturnsPreviouslyFetchedReleaseIfCurrentVersionIsUnknown() async throws {
    makeMonitor(currentVersion: .unknown)
    let expectedRelease = Release(version: "1.0.0")
    localStore.stubs.latestRelease = {
      VersionedRelease(release: expectedRelease, timestamp: Date.daysAgo(6).timeIntervalSince1970)
    }

    let release = try await monitor.availableUpdate()

    XCTAssertEqual(try XCTUnwrap(release), expectedRelease)
  }

  /// Tests that a GitHub release is returned when there are no cached releases.
  func testRequestsFromGitHubIfNoPreviouslyFetchedRelease() async throws {
    localStore.stubs.latestRelease = { nil }
    let expectedRelease = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: expectedRelease.version.description)
    }

    let release = try await monitor.availableUpdate()

    try assertReleaseIgnoreDate(release, expectedRelease: expectedRelease)
  }

  /// Tests that a GitHub release is returned when the cached release is older than a week.
  func testRequestsFromGitHubIfPreviouslyFetchedReleaseIsAWeekOld() async throws {
    localStore.stubs.latestRelease = {
      VersionedRelease(
        release: Release(version: "1.2.0"), timestamp: Date.daysAgo(7).timeIntervalSince1970)
    }
    let expectedRelease = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: expectedRelease.version.description)
    }

    let release = try await monitor.availableUpdate()

    try assertReleaseIgnoreDate(release, expectedRelease: expectedRelease)
  }

  /// Tests that a GitHub release is returned when the cached release matched the current version.
  func testRequestsFromGitHubIfPreviouslyFetchedReleaseIsOfCurrentVersion() async throws {
    localStore.stubs.latestRelease = {
      VersionedRelease(
        release: Release(version: self.defaultCurrentVersion),
        timestamp: Date().timeIntervalSince1970)
    }
    let expectedRelease = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: expectedRelease.version.description)
    }

    let release = try await monitor.availableUpdate()

    try assertReleaseIgnoreDate(release, expectedRelease: expectedRelease)
  }

  /// Tests that a GitHub release is returned when fetching of the cached release failed.
  func testRequestsFromGitHubIfFailsToFetchPreviouslyFetchedRelease() async throws {
    localStore.stubs.latestRelease = { throw LocalStoreError.releaseDecodingFailed(Data()) }
    let expectedRelease = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: expectedRelease.version.description)
    }

    let release = try await monitor.availableUpdate()

    try assertReleaseIgnoreDate(release, expectedRelease: expectedRelease)
  }

  /// Tests that a `nil` release is returned when GitHub release has no workflow file.
  func testNilIsReturnedIfGitHubReleaseHasNotWorkflowFile() async throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(
        tagName: "1.1.0",
        workflow: Asset(
          name: "LingueSearch.zip",
          browserDownloadURL: URL(string: "https://example.com/release_archive")!))
    }

    do {
      let release = try await monitor.availableUpdate()
      XCTFail("The check should have failed, but got \(release.debugDescription)")
    } catch {
      if case UpdateMonitorError.workflowNotFound(_) = error {
        return
      }
      XCTFail("Unexpected error: \(error)")
    }
  }

  /// Tests that `nil` is returned, when GitHub release has the same version as the current one.
  func testNilIsReturnedIfGitHubReleaseIsOfCurrentVersion() async throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: self.defaultCurrentVersion.description)
    }

    let release = try await monitor.availableUpdate()

    XCTAssertNil(release)
  }

  /// Tests that a GitHub release is returned when the current version is unknown.
  func testGitHubReleaseIsReturnedIfCurrentVersionIsUnknown() async throws {
    makeMonitor(currentVersion: .unknown)
    localStore.stubs.latestRelease = { nil }
    let expectedRelease = Release(version: "1.0.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: expectedRelease.version.description)
    }

    let release = try await monitor.availableUpdate()

    try self.assertReleaseIgnoreDate(release, expectedRelease: expectedRelease)
  }

  /// Tests that `nil` is returned when a GitHub release is older the current version.
  func testNilIsReturnedIfGitHubReleaseIsOfOlderVersion() async throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in LatestRelease(tagName: "0.9.0") }

    let release = try await monitor.availableUpdate()

    XCTAssertNil(release)
  }

  /// Tests that a GitHub release is stored.
  func testGitHubReleaseIsStored() async throws {
    localStore.stubs.latestRelease = { nil }
    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: release.version.description)
    }
    var storedRelease: Release?
    localStore.stubs.saveLatestRelease = { release in storedRelease = release }

    let _ = try await monitor.availableUpdate()

    try self.assertReleaseIgnoreDate(storedRelease, expectedRelease: release)
  }

  /// Tests that a GitHub release is stored, when it is not an update candidate.
  func testGitHubReleaseIsStoredIfItIsNotAnUpgrade() async throws {
    localStore.stubs.latestRelease = { nil }
    let release = Release(version: defaultCurrentVersion)
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: release.version.description)
    }
    var storedRelease: Release?
    localStore.stubs.saveLatestRelease = { release in storedRelease = release }

    let _ = try await monitor.availableUpdate()

    try self.assertReleaseIgnoreDate(storedRelease, expectedRelease: release)
  }

  /// Tests that an error is returned when no GitHub releases are found.
  func testNilIsReturnedIfNoGitHubReleaseReturned() async throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in throw GitHubAPIError.notFound }

    do {
      let release = try await monitor.availableUpdate()
      XCTFail("Unexpected result: \(release.debugDescription)")
    } catch {
      guard case GitHubAPIError.notFound = error else {
        XCTFail("Unexpected error: \(error)")
        return
      }
    }
  }

  /// Tests that an error is returned when GitHub request fails.
  func testFailsIfGitHubRequestFails() async throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in throw GitHubAPIError.badResponseCode }

    do {
      let release = try await monitor.availableUpdate()
      XCTFail("Unexpect result: \(release.debugDescription)")
    } catch {
      if case GitHubAPIError.badResponseCode = error {
        return
      }
      XCTFail("Unexpected error: \(error)")
    }
  }

  /// Tests that a GitHub request attempt completion timestamp is stored before the request is sent.
  func testAttemptTimestampIsStoredOnGitHubRequest() async throws {
    localStore.stubs.latestRelease = { nil }
    var requestTime: Date?
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      requestTime = Date()
      throw GitHubAPIError.notFound
    }
    localStore.stubs.checkAttemptTimestamp = { nil }
    var storedAttemptTimestamp: TimeInterval?
    var storedAttemptTime: Date?
    localStore.stubs.saveCheckAttemptTimestamp = { timestamp in
      storedAttemptTime = Date()
      storedAttemptTimestamp = timestamp
    }

    do {
      let release = try await monitor.availableUpdate()
      XCTFail("Unexpect result: \(release.debugDescription)")
    } catch {
      guard case GitHubAPIError.notFound = error else {
        XCTFail("Unexpected error: \(error)")
        return
      }
    }

    let attemptTimestamp = try XCTUnwrap(storedAttemptTimestamp)
    let storeAttemptDate = try XCTUnwrap(storedAttemptTime)
    let requestDate = try XCTUnwrap(requestTime)
    XCTAssertLessThan(storeAttemptDate, requestDate)
    XCTAssertLessThan(attemptTimestamp, requestDate.timeIntervalSince1970)
  }

  /// Tests that a GitHub request is not sent when the previous attempt was sent less than
  /// `requestInterval` minutes ago.
  func testGitHubRequestIsNotSentIfPreviousAttemptWasLessThanRequestIntervalAgo() async throws {
    localStore.stubs.latestRelease = { nil }
    localStore.stubs.checkAttemptTimestamp = { Date.minutesAgo(1).timeIntervalSince1970 }

    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      XCTFail("Request should not be sent")
      throw GitHubAPIError.badResponseCode
    }

    let release = try await monitor.availableUpdate()

    XCTAssertNil(release)
  }

  /// Tests that an attempt timestmap is not updated when a GitHub request was not sent.
  func testAttemptTimestampIsNotUpdatedIfNotGitHubRequestIsSent() async throws {
    localStore.stubs.latestRelease = { nil }
    localStore.stubs.checkAttemptTimestamp = { Date.minutesAgo(1).timeIntervalSince1970 }

    localStore.stubs.saveCheckAttemptTimestamp = { _ in XCTFail("Attempt should not be updated") }

    let release = try await monitor.availableUpdate()

    XCTAssertNil(release)
  }

  /// Tests that an attempt timestamp is not updated when a cached release is returned.
  func testAttemptTimestampNotUpdatedIfCachedReleaseIsReturned() async throws {
    let expectedRelease = Release(version: "1.1.0")
    localStore.stubs.latestRelease = {
      VersionedRelease(release: expectedRelease, timestamp: Date().timeIntervalSince1970)
    }

    localStore.stubs.saveCheckAttemptTimestamp = { _ in XCTFail("Attempt should not be updated") }

    let release = try await monitor.availableUpdate()

    XCTAssertEqual(release, expectedRelease)
  }

  /// Tests that a GitHub request is sent when the previous attempt was sent more than
  /// `requestInterval` ago.
  func testGitHubRequestIsSentAfterMoreThanRequestIntervalSincePreviousAttempt() async throws {
    localStore.stubs.latestRelease = { nil }
    localStore.stubs.checkAttemptTimestamp = { Date.minutesAgo(3).timeIntervalSince1970 }
    localStore.stubs.saveCheckAttemptTimestamp = { _ in }

    let expectedRelease = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      LatestRelease(tagName: expectedRelease.version.description)
    }

    let release = try await monitor.availableUpdate()

    try self.assertReleaseIgnoreDate(release, expectedRelease: expectedRelease)
  }

  // MARK: - Private

  /// Initializes the `monitor` with a new instance using `currentVersion`.
  private func makeMonitor(currentVersion: Version) {
    monitor = UpdateMonitor(
      currentVersion: currentVersion,
      requestInterval: requestInterval,
      cacheExpirationInterval: cacheExpirationInterval,
      localStore: localStore,
      gitHubAPI: gitHubAPI)
  }

  /// Asserts that the `receivedReleases` have only one non-nil release, that matches the `release`
  /// in all fields, but `releaseDate`.
  func assertReleasesIgnoreDate(_ receivedReleases: [Release?], expectedRelease release: Release)
    throws
  {
    XCTAssertEqual(receivedReleases.count, 1)
    try self.assertReleaseIgnoreDate(
      try XCTUnwrap(receivedReleases.last),
      expectedRelease: release)
  }

  /// Asserts that the `receivedRelease` matches the `expectedRelease `in all fields, but
  /// `releaseDate`.
  func assertReleaseIgnoreDate(_ receivedRelease: Release?, expectedRelease: Release) throws {
    let release = try XCTUnwrap(receivedRelease)
    XCTAssertEqual(release.version, expectedRelease.version)
    XCTAssertEqual(release.releaseURL, expectedRelease.releaseURL)
    XCTAssertEqual(release.workflowURL, expectedRelease.workflowURL)
    XCTAssertGreaterThanOrEqual(release.releaseDate, expectedRelease.releaseDate)
  }
}
