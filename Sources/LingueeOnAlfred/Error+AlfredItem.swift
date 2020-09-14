import Alfred

extension Error {
  var alfredItem: Item {
    return .init(
      valid: false, title: "Failed to get translations!", subtitle: "Detalis: \(self)",
      icon: .warning)
  }
}
