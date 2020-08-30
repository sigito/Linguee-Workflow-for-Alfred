import Foundation

struct Items: Encodable {
  private(set) var items: [Item] = []

  mutating func add(_ item: Item) {
    self.items.append(item)
  }

  mutating func insert(_ item: Item, at index: Int) {
    items.insert(item, at: index)
  }
}

public struct Modifier: Encodable {
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

public struct Mods: Encodable {
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

public struct Text: Encodable {
  public enum Option {
    case copy
    case largeType
  }

  private enum CodingKeys: String, CodingKey {
    case copy
    case largeType = "largetype"
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

public enum Icon {
  /// Display an icon at the passed location.
  case icon(location: String)
  /// Display an icon for the path.
  case fileIcon(forPath: String)
  /// Display an icon of a specific file.
  case fileType(of: String)
}

extension Icon: Encodable {
  private enum CodingKeys: String, CodingKey {
    case type
    case path
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .icon(location: let path):
      // No type for icon.
      try container.encode(path, forKey: .path)
    case .fileIcon(forPath: let path):
      try container.encode("fileicon", forKey: .type)
      try container.encode(path, forKey: .path)
    case .fileType(of: let path):
      try container.encode("filetype", forKey: .type)
      try container.encode(path, forKey: .path)
    }
  }
}

/// See https://www.alfredapp.com/help/workflows/inputs/script-filter/json/ for fields descriptions.
public struct Item: Encodable {
  public var uid: String?
  // TODO: remove `valid` and infer it based on the `arg` presence.
  public var valid: Bool
  public var title: String
  public var subtitle: String?
  public var arg: String?
  public var icon: Icon?
  public var autocomplete: String?
  public var mods: Mods?
  public var text: Text?
  /// A Quick Look URL which will be visible if the user uses the Quick Look feature within Alfred
  /// (tapping shift, or cmd+y).
  public var quickLookURL: String?

  private enum CodingKeys: String, CodingKey {
    case uid
    case valid
    case title
    case subtitle
    case arg
    case icon
    case autocomplete
    case mods
    case text
    case quickLookURL = "quicklookurl"
  }

  public init(
    uid: String? = nil,
    valid: Bool = true,
    title: String,
    subtitle: String? = nil,
    arg: String? = nil,
    icon: Icon? = nil,
    autocomplete: String? = nil,
    mods: [Mods.Key: Modifier] = [:],
    text: [Text.Option: String] = [:],
    quickLookURL: String? = nil
  ) {
    self.uid = uid
    self.valid = valid
    self.title = title
    self.subtitle = subtitle
    self.arg = arg
    self.icon = icon
    self.autocomplete = autocomplete
    self.mods = Mods(modifiers: mods)
    self.text = Text(options: text)
    self.quickLookURL = quickLookURL
  }
}
