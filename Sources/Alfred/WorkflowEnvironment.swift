import Foundation

/// Environment variables accessor.
///
/// See https://www.alfredapp.com/help/workflows/script-environment-variables/ for descriptions.
public struct WorkflowEnvironment {
  public let environment: [String: String]

  public init(environment: [String: String] = ProcessInfo.processInfo.environment) {
    self.environment = environment
  }

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
