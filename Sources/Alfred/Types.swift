struct Items: Encodable {
  private(set) var items: [Item] = []

  mutating func add(_ item: Item) {
    return self.items.append(item)
  }
}

public struct Modifier : Encodable {
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

public struct Mods : Encodable {
  public let alt: Modifier?
  public let cmd: Modifier?

  /// Private initializer, since we do not want to have an object with both keys set to `nil`.
  private init(alt: Modifier? = nil, cmd: Modifier? = nil) {
    self.alt = alt
    self.cmd = cmd
  }

  public static func alt(_ modifier: Modifier) -> Self {
    return .init(alt: modifier)
  }

  public static func cmd(_ modifier: Modifier) -> Self {
    return .init(cmd: modifier)
  }
}

/// See https://www.alfredapp.com/help/workflows/inputs/script-filter/json/ for fields descriptions.
public struct Item : Encodable {
  public var uid: String?
  // TODO: remove `valid` and infer it based on the `arg` presence.
  public var valid: Bool
  public var title: String
  public var subtitle: String?
  public var arg: String?
  public var autocomplete: String?
  public var mods: Mods?

  public init(
    uid: String? = nil,
    valid: Bool = true,
    title: String,
    subtitle: String? = nil,
    arg: String? = nil,
    autocomplete: String? = nil,
    mods: Mods? = nil
  ) {
    self.uid = uid
    self.valid = valid
    self.title = title
    self.subtitle = subtitle
    self.arg = arg
    self.autocomplete = autocomplete
    self.mods = mods
  }
}
