import Foundation

enum LocalStoreError: Error {
  case rootDirectoryCreationFailed(URL, underlyingError: Error? = nil)
  case readFailed(URL, underlyingError: Error? = nil)
  case writeFailed(URL, underlyingError: Error? = nil)
  case releaseDecodingFailed(Data, underlyingError: Error? = nil)
  case releaseEncodingFalied(Release, underlyingError: Error? = nil)
}

/// A release with the timestamp of when it was stored.
public struct VersionedRelease: Codable {
  /// The stored release.
  let release: Release
  /// The unix timestamp of the moment the release was stored.
  let timestamp: TimeInterval
}

public protocol LocalStore {
  func currentVersion() throws -> String

  func latestRelease() throws -> VersionedRelease?
  func save(latestRelease release: Release) throws

  func checkAttemptTimestamp() throws -> TimeInterval?
  func save(checkAttemptTimestamp timestamp: TimeInterval) throws
}

protocol FileAccessing {
  func createDirectory(at url: URL, withIntermediateDirectories: Bool) throws
  func fileExists(atPath path: String) -> Bool

  func read(contentsOf url: URL) throws -> Data
  func read(contentsOf url: URL) throws -> String
  func read<T>(contentsOf url: URL) throws -> T? where T: LosslessStringConvertible

  func write(_ data: Data, to url: URL) throws
  func write(string: String, to url: URL) throws
  func write<T>(_ object: T, to url: URL) throws where T: LosslessStringConvertible
}

extension FileAccessing {
  func read(contentsOf url: URL) throws -> Data {
    return try Data(contentsOf: url)
  }

  func read(contentsOf url: URL) throws -> String {
    return try String(contentsOf: url, encoding: .utf8)
  }

  func read<T>(contentsOf url: URL) throws -> T? where T: LosslessStringConvertible {
    return try T(read(contentsOf: url))
  }

  func write(_ data: Data, to url: URL) throws {
    try data.write(to: url, options: .atomicWrite)
  }

  func write(string: String, to url: URL) throws {
    try string.write(to: url, atomically: true, encoding: .utf8)
  }

  func write<T>(_ object: T, to url: URL) throws where T: LosslessStringConvertible {
    try String(object).write(to: url, atomically: true, encoding: .utf8)
  }
}

extension FileManager: FileAccessing {
  func createDirectory(at url: URL, withIntermediateDirectories: Bool) throws {
    try createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories)
  }
}

class LocalStoreImpl: LocalStore {
  private let fileAccessor: FileAccessing

  private let rootDir: URL
  private let versionFile: URL
  private let latestReleaseFile: URL
  private let lastCheckAttemptTimestampFile: URL

  // TODO: use `alfred_workflow_cache` variable instead.
  // https://www.alfredapp.com/help/workflows/script-environment-variables/
  init(
    rootDir: URL = URL(fileURLWithPath: ".updater", isDirectory: true),
    fileAccessor: FileAccessing = FileManager.default
  ) throws {
    do {
      try fileAccessor.createDirectory(at: rootDir, withIntermediateDirectories: true)
    } catch {
      throw LocalStoreError.rootDirectoryCreationFailed(rootDir, underlyingError: error)
    }
    self.fileAccessor = fileAccessor
    // TODO: version does not fit the definition.
    // TODO: read version from `alfred_workflow_version` instead.
    // https://www.alfredapp.com/help/workflows/script-environment-variables/
    self.versionFile = URL(fileURLWithPath: "version", isDirectory: false)
    self.rootDir = rootDir
    self.latestReleaseFile = URL(
      fileURLWithPath: ".latest_update", isDirectory: false, relativeTo: rootDir)
    self.lastCheckAttemptTimestampFile = URL(
      fileURLWithPath: "last_attempt", isDirectory: false, relativeTo: rootDir)
  }

  /// Returns the current version of the workflow.
  /// - Throws: `LocalStoreError.readFailed` if failed to read the version.
  func currentVersion() throws -> String {
    do {
      return try fileAccessor.read(contentsOf: versionFile)
    } catch {
      throw LocalStoreError.readFailed(versionFile, underlyingError: error)
    }
  }

  /// Returns the latest known release.
  /// - Returns: The letast known release or `nil` if have been previously stored.
  /// - Throws:
  ///   - `LocalStoreError.readFailed`, if the failed to read a previosly stored release.
  ///   - `LocalStoreError.releaseDecodingFailed`, if the stored release has unexpected format.
  func latestRelease() throws -> VersionedRelease? {
    guard fileAccessor.fileExists(atPath: latestReleaseFile.path) else {
      // Not an issues, there were no fetched updates yet.
      return nil
    }
    let data: Data
    do {
      data = try fileAccessor.read(contentsOf: latestReleaseFile)
    } catch {
      throw LocalStoreError.readFailed(latestReleaseFile, underlyingError: error)
    }
    let decoder = JSONDecoder()
    do {
      return try decoder.decode(VersionedRelease.self, from: data)
    } catch {
      throw LocalStoreError.releaseDecodingFailed(data, underlyingError: error)
    }
  }

  /// Updates the latest known release with `release`.
  ///
  /// - Parameter release The release to save.
  /// - Throws:
  ///   - `LocalStoreError.releaseEncodingFailed`, if the `release` encoding has been unsuccessful.
  ///   - `LocalStoreError.writeFailed`, if failed to write the `release`.
  func save(latestRelease release: Release) throws {
    let timestampedRelease = VersionedRelease(
      release: release,
      timestamp: Date().timeIntervalSince1970)
    let encoder = JSONEncoder()
    let data: Data
    do {
      data = try encoder.encode(timestampedRelease)
    } catch {
      throw LocalStoreError.releaseEncodingFalied(release, underlyingError: error)
    }
    do {
      try fileAccessor.write(data, to: latestReleaseFile)
    } catch {
      throw LocalStoreError.writeFailed(latestReleaseFile, underlyingError: error)
    }
  }

  /// Returns the check attempt timestamp, if available.
  /// - Returns: The check attempt timestamp or `nil` if have been previously stored.
  /// - Throws:
  ///   - `LocalStoreError.readFailed`, if the failed to read the stored timestamp.
  func checkAttemptTimestamp() throws -> TimeInterval? {
    do {
      return try fileAccessor.read(contentsOf: lastCheckAttemptTimestampFile)
    } catch {
      throw LocalStoreError.readFailed(lastCheckAttemptTimestampFile, underlyingError: error)
    }
  }

  /// Updates the check attempt timestamp.
  ///
  /// - Parameter timestamp The new timestamp to save.
  /// - Throws:
  ///   - `LocalStoreError.writeFailed`, if failed to write the `timestamp`.
  func save(checkAttemptTimestamp timestamp: TimeInterval) throws {
    do {
      try fileAccessor.write(timestamp, to: lastCheckAttemptTimestampFile)
    } catch {
      throw LocalStoreError.writeFailed(lastCheckAttemptTimestampFile, underlyingError: error)
    }
  }
}
