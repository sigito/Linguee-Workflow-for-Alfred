enum Alfred {

  struct Items: Codable {
    private(set) var items: [Item] = []

    mutating func add(_ item: Item) {
      return self.items.append(item)
    }
  }

  struct Item : Codable {
    var uid: String? = nil
    var valid: Bool = true
    var title: String
    var subtitle: String
    var arg: String
  }

}

