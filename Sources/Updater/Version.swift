import Foundation
import Logging

public struct Version {
  public var major: Int
  public var minor: Int
  public var patch: Int

  public init(major: Int, minor: Int = 0, patch: Int = 0) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }
}

extension Version: Codable {}

extension Version: Equatable {}

extension Version: Comparable {
  public static func < (lhs: Version, rhs: Version) -> Bool {
    let lhsComponents = [lhs.major, lhs.minor, lhs.patch]
    let rhsComponents = [rhs.major, rhs.minor, rhs.patch]
    return lhsComponents.lexicographicallyPrecedes(rhsComponents)
  }
}

extension Version {
  public static var unknown = Version(major: 0, minor: 0, patch: 0)

  public init?(_ value: String) {
    let logger =
      Logger(
        label: "\(Self.self)", factory: StreamLogHandler.standardError(label:))
    let stringComponents = value.split(separator: ".").map(String.init)
    guard (1...3).contains(stringComponents.count) else {
      logger.error("Unexpected components count in version string: '\(value)'")
      return nil
    }
    let components = stringComponents.compactMap(Int.init)
    guard components.count == stringComponents.count else {
      logger.error("Failed to convert components to integer values for version string: '\(value)'")
      return nil
    }

    let major = components[0]
    let minor = components.count > 1 ? components[1] : 0
    let patch = components.count > 2 ? components[2] : 0
    self.init(major: major, minor: minor, patch: patch)
  }
}

extension Version: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    let version = Version(value) ?? .unknown
    self = version
  }
}

extension Version: CustomStringConvertible {
  public var description: String {
    return "\(major).\(minor).\(patch)"
  }
}
