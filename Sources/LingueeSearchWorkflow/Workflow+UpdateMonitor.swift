import Alfred

extension WorkflowEnvironment {
  /// Whether the updates monitoring is enabled.
  var checkForUpdates: Bool {
    return bool(forKey: "check_for_updates")
  }
}
