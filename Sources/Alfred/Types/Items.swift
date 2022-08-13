struct Items {
  private(set) var items: [Item] = []

  mutating func add(_ item: Item) {
    self.items.append(item)
  }

  mutating func insert(_ item: Item, at index: Int) {
    items.insert(item, at: index)
  }
}

extension Items: Encodable {}
