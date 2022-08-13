public struct Mods {
  public enum Key {
    case alt
    case cmd
  }

  public let alt: Modifier?
  public let cmd: Modifier?

  public init?(modifiers: [Key: Modifier]) {
    guard !modifiers.isEmpty else {
      // At least one modifier must be provided
      return nil
    }
    self.alt = modifiers[.alt]
    self.cmd = modifiers[.cmd]
  }
}

extension Mods: Codable {}
