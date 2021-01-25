import Foundation
import XCTest

@testable import Updater

class VersionTest: XCTestCase {
  private let version1_2_3 = Version(major: 1, minor: 2, patch: 3)

  /// Tests that the `init?(_ value:)` properly parses a full version string.
  func testParseMajorMinorPatch() {
    XCTAssertEqual(Version("1.2.3"), version1_2_3)
  }

  /// Tests that the `init?(_ value:)` properly parses a version string with two components.
  func testParseMajorMinor() {
    XCTAssertEqual(Version("1.2"), Version(major: 1, minor: 2))
  }

  /// Tests that the `init?(_ value:)` properly parses a version string with one component.
  func testParseMajor() {
    XCTAssertEqual(Version("1"), Version(major: 1))
  }

  /// Tests that the `init?(_ value:)` returns `nil` for an empty version string.
  func testParseEmptyString() {
    let emptyString = ""
    XCTAssertNil(Version(emptyString))
  }

  /// Tests that the `init?(_ value:)` returns `nil` for a version string with too many formats.
  func testParseTooManyComponents() {
    let versionString = "1.2.3.4"
    XCTAssertNil(Version(versionString))
  }

  /// Tests that the `init?(_ value:)` returns `nil` for a version string containing unexpected
  /// characters.
  func testParseBadVersionString() {
    let versionString = "1.2.bla"
    XCTAssertNil(Version(versionString))
  }
}

// MARK: - Description

extension VersionTest {

  /// Tests that the description returns a string in format `{major}.{minor}.{patch}`.
  func testDescription() {
    XCTAssertEqual(Version("1.2.3").description, "1.2.3")
  }
}

// MARK: - Comparable

extension VersionTest {

  /// Tests that a smaller version is smaller.
  func testComparisonLess() {
    let version1 = Version("1.1.0")
    let version2 = Version("1.1.1")
    XCTAssertLessThan(version1, version2)
  }

  /// Tests that the same versions are equal.
  func testComparisonEqual() {
    XCTAssertEqual(Version("6.4.2"), Version("6.4.2"))
  }

  /// Tests that a bigger version is bigger.
  func testComparisonGreater() {
    XCTAssertGreaterThan(Version("5.8.3"), Version("5.7.6"))
  }

  /// Tests that the version are compared using semantic order.
  func testComparisonSemanticOrder() {
    XCTAssertLessThan(Version("2.1.2"), Version("10.1.2"))
  }
}
