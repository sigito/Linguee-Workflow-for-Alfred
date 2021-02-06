import Foundation

/// The last position in the Alfred's result list, that is visible by default.
fileprivate let lastVisiblePosition = 8

public struct Workflow {

  private var itemsContainer = Items()
  public var items: [Item] {
    return self.itemsContainer.items
  }

  public init() {}

  public mutating func add(_ item: Item) {
    self.itemsContainer.add(item)
  }

  /// Inserts the `item` at the last visible position.
  ///
  /// If the number of items is smaller than visible on the screen, the `item` is added at the end
  /// of the list, otherwise the last visible position.
  public mutating func addAtLastVisiblePosition(_ item: Item) {
    guard self.itemsContainer.items.count > lastVisiblePosition else {
      self.itemsContainer.add(item)
      return
    }
    self.itemsContainer.insert(item, at: lastVisiblePosition)
  }

  public func emit() throws {
    let jsonData = try JSONEncoder().encode(self.itemsContainer)
    guard let json = String(data: jsonData, encoding: .utf8) else {
      fatalError()
    }
    print(json)
  }
}
