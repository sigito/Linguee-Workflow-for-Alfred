import Combine
import Foundation
import XCTest

@testable import Updater

class UpdateMonitorTest: XCTestCase {
  private var localStore: LocalStoreFake!
  private var gitHubAPI: GitHubAPIFake!
  private var monitor: UpdateMonitor!
  private var receivedAvailableUpdate: Release? = nil
  private let releaseSubscriber = TestSubscriber<Release?, UpdateMonitorError>()
  private let requestInterval: Int = 2 * 60  // 2 minute
  private let defaultCurrentVersion = "1.0.0"

  override func setUpWithError() throws {
    localStore = LocalStoreFake()
    gitHubAPI = GitHubAPIFake()
    makeMonitor(currentVersion: defaultCurrentVersion)
  }

  /// Tests that a previously fetched release is returned, when its version is newer than current,
  /// and the release was fetche within last week.
  func testReturnsPrevioslyFetchedReleaseIfNew() throws {
    let release = Release(version: "1.1.0")
    let twoDaysAgo = Date.daysAgo(2)
    localStore.stubs.latestRelease = {
      VersionedRelease(release: release, timestamp: twoDaysAgo.timeIntervalSince1970)
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [release])
  }

  /// Tests that when the current version of the workflow is unknown, the cached release is
  /// returned.
  func testReturnsPreviouslyFetchedReleaseIfCurrentVersionIsUnknown() throws {
    makeMonitor(currentVersion: nil)
    let release = Release(version: "1.0.0")
    localStore.stubs.latestRelease = {
      VersionedRelease(release: release, timestamp: Date.daysAgo(6).timeIntervalSince1970)
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [release])
  }

  /// Tests that a GitHub release is returned when there are no cached releases.
  func testRequestsFromGitHubIfNoPreviouslyFetchedRelease() throws {
    localStore.stubs.latestRelease = { nil }
    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try assertReleasesIgnoreDate(releaseSubscriber.receivedValues, expectedRelease: release)
  }

  /// Tests that a GitHub release is returned when the cached release is older than a week.
  func testRequestsFromGitHubIfPreviouslyFetchedReleaseIsAWeekOld() throws {
    localStore.stubs.latestRelease = {
      VersionedRelease(
        release: Release(version: "1.2.0"), timestamp: Date.daysAgo(7).timeIntervalSince1970)
    }
    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try assertReleasesIgnoreDate(releaseSubscriber.receivedValues, expectedRelease: release)
  }

  /// Tests that a GitHub release is returned when the cached release matched the current version.
  func testRequestsFromGitHubIfPreviouslyFetchedReleaseIsOfCurrentVersion() throws {
    localStore.stubs.latestRelease = {
      VersionedRelease(
        release: Release(version: self.defaultCurrentVersion),
        timestamp: Date().timeIntervalSince1970)
    }
    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try assertReleasesIgnoreDate(releaseSubscriber.receivedValues, expectedRelease: release)
  }

  /// Tests that a GitHub release is returned when fetching of the cached release failed.
  func testRequestsFromGitHubIfFailsToFetchPreviouslyFetchedRelease() throws {
    localStore.stubs.latestRelease = { throw LocalStoreError.releaseDecodingFailed(Data()) }
    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try assertReleasesIgnoreDate(releaseSubscriber.receivedValues, expectedRelease: release)
  }

  /// Tests that a `nil` release is returned when GitHub release has no workflow file.
  func testNilIsReturnedIfGitHubReleaseHasNotWorkflowFile() throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(
        LatestRelease(
          tagName: "1.1.0",
          workflow: Asset(
            name: "LingueSearch.zip",
            browserDownloadURL: URL(string: "https://example.com/release_archive")!)))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertError { (error) in
      if case .workflowNotFound(_) = error {
        return
      }
      XCTFail("Unexpected error: \(error)")
    }
    XCTAssertEqual(releaseSubscriber.receivedValues, [])
  }

  /// Tests that `nil` is returned, when GitHub release has the same version as the current one.
  func testNilIsReturnedIfGitHubReleaseIsOfCurrentVersion() throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: self.defaultCurrentVersion))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [nil])
  }

  /// Tests that a GitHub release is returned when the current version is unknown.
  func testGitHubReleaseIsReturnedIfCurrentVersionIsUnknown() throws {
    makeMonitor(currentVersion: nil)
    localStore.stubs.latestRelease = { nil }
    let release = Release(version: "1.0.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try self.assertReleasesIgnoreDate(releaseSubscriber.receivedValues, expectedRelease: release)
  }

  /// Tests that `nil` is returned when a GitHub release is older the current version.
  func testNilIsReturnedIfGitHubReleaseIsOfOlderVersion() throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in .success(LatestRelease(tagName: "0.9.0")) }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [nil])
  }

  /// Tests that a GitHub release is stored.
  func testGitHubReleaseIsStored() throws {
    localStore.stubs.latestRelease = { nil }
    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }
    var storedRelease: Release?
    localStore.stubs.saveLatestRelease = { release in storedRelease = release }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try self.assertReleaseIgnoreDate(storedRelease, expectedRelease: release)
  }

  /// Tests that a GitHub release is stored, when it is not an update candidate.
  func testGitHubReleaseIsStoredIfItIsNotAnUpgrade() throws {
    localStore.stubs.latestRelease = { nil }
    let release = Release(version: defaultCurrentVersion)
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }
    var storedRelease: Release?
    localStore.stubs.saveLatestRelease = { release in storedRelease = release }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try self.assertReleaseIgnoreDate(storedRelease, expectedRelease: release)
  }

  /// Tests that `nil` is returned when no GitHub releases found.
  func testNilIsReturnedIfNoGitHubReleaseReturned() throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in .success(nil) }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [nil])
  }

  /// Tests that an error is returned when GitHub request fails.
  func testFailsIfGitHubRequestFails() throws {
    localStore.stubs.latestRelease = { nil }
    gitHubAPI.stubs.latestReleaseResult = { _, _ in .failure(.badResponseCode) }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertError { (error) in
      if case .generic(GitHubAPIError.badResponseCode) = error {
        return
      }
      XCTFail("Unexpected error: \(error)")
    }
    XCTAssertEqual(releaseSubscriber.receivedValues, [])
  }

  /// Tests that a GitHub request attempt completion timestamp is stored before the request is sent.
  func testAttemptTimestampIsStoredOnGitHubRequest() throws {
    localStore.stubs.latestRelease = { nil }
    var requestTime: Date?
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      requestTime = Date()
      return .success(nil)
    }
    localStore.stubs.checkAttemptTimestamp = { nil }
    var storedAttemptTimestamp: TimeInterval?
    var storedAttemptTime: Date?
    localStore.stubs.saveCheckAttemptTimestamp = { timestamp in
      storedAttemptTime = Date()
      storedAttemptTimestamp = timestamp
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [nil])

    let attepmtTimestamp = try XCTUnwrap(storedAttemptTimestamp)
    let storeAttemptDate = try XCTUnwrap(storedAttemptTime)
    let requestDate = try XCTUnwrap(requestTime)
    XCTAssertLessThan(storeAttemptDate, requestDate)
    XCTAssertLessThan(attepmtTimestamp, requestDate.timeIntervalSince1970)
  }

  /// Tests that a GitHub request is not sent when the previous attempt was sent less than
  /// `requestInterval` minutes ago.
  func testGitHubRequestIsNotSentIfPreviousAttemptWasLessThanRequestIntervalAgo() throws {
    localStore.stubs.latestRelease = { nil }
    localStore.stubs.checkAttemptTimestamp = { Date.minutesAgo(1).timeIntervalSince1970 }

    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      XCTFail("Request should not be sent")
      return .success(nil)
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [nil])
  }

  /// Tests that an attempt timestmap is not updated when a GitHub request was not sent.
  func testAttemptTimestampIsNotUpdatedIfNotGitHubRequestIsSent() throws {
    localStore.stubs.latestRelease = { nil }
    localStore.stubs.checkAttemptTimestamp = { Date.minutesAgo(1).timeIntervalSince1970 }

    localStore.stubs.saveCheckAttemptTimestamp = { _ in XCTFail("Attempt should not be updated") }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [nil])
  }

  /// Tests that an attempt timestamp is not updated when a cached release is returned.
  func testAttemptTimestampNotUpdatedIfCachedReleaseIsReturned() throws {
    let release = Release(version: "1.1.0")
    localStore.stubs.latestRelease = {
      VersionedRelease(release: release, timestamp: Date().timeIntervalSince1970)
    }

    localStore.stubs.saveCheckAttemptTimestamp = { _ in XCTFail("Attempt should not be updated") }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(releaseSubscriber.receivedValues, [release])
  }

  /// Tests that a GitHub request is sent when the previous attempt was sent more than
  /// `requestInterval` ago.
  func testGitHubRequestIsSentAfterMoreThanRequestIntervalSincePreviousAttempt() throws {
    localStore.stubs.latestRelease = { nil }
    localStore.stubs.checkAttemptTimestamp = { Date.minutesAgo(3).timeIntervalSince1970 }
    localStore.stubs.saveCheckAttemptTimestamp = { _ in }

    let release = Release(version: "1.1.0")
    gitHubAPI.stubs.latestReleaseResult = { _, _ in
      .success(LatestRelease(tagName: release.version))
    }

    let _ = monitor.availableUpdate().subscribe(releaseSubscriber)

    releaseSubscriber.waitForCompletion()?.assertSuccess()
    try self.assertReleasesIgnoreDate(releaseSubscriber.receivedValues, expectedRelease: release)
  }

  // MARK: - Private

  /// Initializes the `monitor` with a new instance using `currentVersion`
  private func makeMonitor(currentVersion: String?) {
    monitor = UpdateMonitor(
      currentVersion: currentVersion,
      requestInterval: requestInterval,
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
