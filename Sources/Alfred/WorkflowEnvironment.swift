import Foundation

/// Environment variables accessor.
///
/// See https://www.alfredapp.com/help/workflows/script-environment-variables/ for descriptions.
public struct WorkflowEnvironment {
  public let environment: [String: String]

  public init(environment: [String: String] = ProcessInfo.processInfo.environment) {
    self.environment = environment
  }

  public static let `default` = WorkflowEnvironment()

  public var workflowVersion: String? {
    return environment["alfred_workflow_version"]
  }

  public var workflowData: URL? {
    guard let dir = environment["alfred_workflow_data"] else {
      return nil
    }
    return URL(fileURLWithPath: dir, isDirectory: true)
  }

  public var workflowCache: URL? {
    guard let dir = environment["alfred_workflow_cache"] else {
      return nil
    }
    return URL(fileURLWithPath: dir, isDirectory: true)
  }
}

extension WorkflowEnvironment {
  /// Returns an environment bool value for `key`.
  ///
  /// `defaultValue` is returned, if the value is missing for the `key` or is not a `bool`.
  public func bool(forKey key: String, defaultValue: Bool = false) -> Bool {
    guard let value = environment[key] else {
      return defaultValue
    }
    return Bool(value) ?? defaultValue
  }
}
