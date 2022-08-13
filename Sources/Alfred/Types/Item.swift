/// See https://www.alfredapp.com/help/workflows/inputs/script-filter/json/ for fields descriptions.
public struct Item {
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

extension Item: Codable {
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
}
