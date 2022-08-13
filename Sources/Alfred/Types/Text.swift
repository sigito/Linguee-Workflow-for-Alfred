public struct Text {
  public enum Option {
    case copy
    case largeType
  }

  public var copy: String?
  public var largeType: String?

  init?(options: [Option: String]) {
    guard !options.isEmpty else {
      // At least one option must be provided
      return nil
    }
    self.copy = options[.copy]
    self.largeType = options[.largeType]
  }
}

extension Text: Codable {
  private enum CodingKeys: String, CodingKey {
    case copy
    case largeType = "largetype"
  }
}
