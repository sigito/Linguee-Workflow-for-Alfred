import Foundation

@testable import Updater

enum FakeError: Error {
  case notFaked(file: StaticString, line: UInt)
}

extension FakeError: CustomDebugStringConvertible {
  var debugDescription: String {
    if case let .notFaked(file, line) = self {
      return "notFaked(\(file):\(line))"
    }
    return String(describing: self)
  }
}

func notFaked0<R>(file: StaticString = #file, line: UInt = #line) -> () throws -> R {
  return { throw FakeError.notFaked(file: file, line: line) }
}

func notFaked1<T, R>(file: StaticString = #file, line: UInt = #line) -> (T) throws -> R {
  return { _ in throw FakeError.notFaked(file: file, line: line) }
}

class LocalStoreFake: LocalStore {
  class Stubs {
    var currentVersion: () throws -> String = notFaked0()
    var latestRelease: () throws -> VersionedRelease? = notFaked0()
    var saveLatestRelease: (Release) throws -> Void = notFaked1()
    var checkAttemptTimestamp: () throws -> TimeInterval? = notFaked0()
    var saveCheckAttemptTimestamp: (TimeInterval) throws -> Void = notFaked1()
  }

  let stubs = Stubs()

  func currentVersion() throws -> String {
    try stubs.currentVersion()
  }

  func latestRelease() throws -> VersionedRelease? {
    try stubs.latestRelease()
  }

  func save(latestRelease release: Release) throws {
    try stubs.saveLatestRelease(release)
  }

  func checkAttemptTimestamp() throws -> TimeInterval? {
    return try stubs.checkAttemptTimestamp()
  }

  func save(checkAttemptTimestamp timestamp: TimeInterval) throws {
    try stubs.saveCheckAttemptTimestamp(timestamp)
  }
}
