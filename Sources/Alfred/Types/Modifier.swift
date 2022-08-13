public struct Modifier {
  var valid: Bool
  var arg: String?
  var subtitle: String

  public init(
    subtitle: String,
    valid: Bool = true,
    arg: String? = nil
  ) {
    self.subtitle = subtitle
    self.valid = valid
    self.arg = arg
  }
}

extension Modifier: Codable {}
