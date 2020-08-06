public struct Items: Codable {
  private(set) var items: [Item] = []

  public mutating func add(_ item: Item) {
    return self.items.append(item)
  }
}

public struct Item : Codable {
  public var uid: String? = nil
  public var valid: Bool = true
  public var title: String
  public var subtitle: String
  public var arg: String

  public init(
    uid: String? = nil,
    valid: Bool = true,
    title: String,
    subtitle: String,
    arg: String
  ) {
    self.uid = uid
    self.valid = valid
    self.title = title
    self.subtitle = subtitle
    self.arg = arg
  }
}
