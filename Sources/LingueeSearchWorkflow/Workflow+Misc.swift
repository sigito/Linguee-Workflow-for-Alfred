import Alfred

extension WorkflowEnvironment {
  var disableCopyTextPromotion: Bool {
    return bool(forKey: "disable_copy_text_promotion")
  }
}
