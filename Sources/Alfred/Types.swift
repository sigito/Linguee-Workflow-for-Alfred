public struct Items: Codable {
  private(set) var items: [Item] = []

  public mutating func add(_ item: Item) {
    return self.items.append(item)
  }
}

/// See https://www.alfredapp.com/help/workflows/inputs/script-filter/json/ for fields descriptions.
public struct Item : Codable {
  public var uid: String?
  public var valid: Bool
  public var title: String
  public var subtitle: String?
  public var arg: String?
  public var autocomplete: String?

  public init(
    uid: String? = nil,
    valid: Bool = true,
    title: String,
    subtitle: String? = nil,
    arg: String? = nil,
    autocomplete: String? = nil
  ) {
    self.uid = uid
    self.valid = valid
    self.title = title
    self.subtitle = subtitle
    self.arg = arg
    self.autocomplete = autocomplete
  }
}
