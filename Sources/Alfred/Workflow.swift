import Foundation

fileprivate let mockResults = """
  {
    "items": [
      {
        "uid": "desktop",
        "type": "file",
        "title": "Desktop",
        "subtitle": "~/Desktop",
        "arg": "~/Desktop",
        "autocomplete": "Desktop",
        "icon": {
          "type": "fileicon",
          "path": "~/Desktop"
        }
      },
      {
        "valid": false,
        "uid": "flickr",
        "title": "Flickr",
        "icon": {
          "path": "flickr.png"
        }
      },
      {
        "uid": "image",
        "type": "file",
        "title": "My holiday photo",
        "subtitle": "~/Pictures/My holiday photo.jpg",
        "autocomplete": "My holiday photo",
        "icon": {
          "type": "filetype",
          "path": "public.jpeg"
        }
      },
      {
        "valid": false,
        "uid": "alfredapp",
        "title": "Alfred Website",
        "subtitle": "https://www.alfredapp.com/",
        "arg": "alfredapp.com",
        "autocomplete": "Alfred Website",
        "quicklookurl": "https://www.alfredapp.com/",
        "mods": {
          "alt": {
            "valid": true,
            "arg": "alfredapp.com/powerpack",
            "subtitle": "https://www.alfredapp.com/powerpack/"
          },
          "cmd": {
            "valid": true,
            "arg": "alfredapp.com/powerpack/buy/",
            "subtitle": "https://www.alfredapp.com/powerpack/buy/"
          },
        },
        "text": {
          "copy": "https://www.alfredapp.com/ (text here to copy)",
          "largetype": "https://www.alfredapp.com/ (text here for large type)"
        }
      }
    ]
  }
  """

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
