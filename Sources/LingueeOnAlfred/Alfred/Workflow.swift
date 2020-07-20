//
//  File.swift
//  
//
//  Created by Yurii Samsoniuk on 19.07.20.
//

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

extension Alfred {
  struct Workflow {

  private var items = Items()

  mutating func add(_ item: Item) {
    self.items.add(item)
  }

  func emit() throws {
    let jsonData = try JSONEncoder().encode(self.items)
    guard let json = String(data: jsonData, encoding: .utf8) else {
      fatalError()
    }
    print(json)
  }
}
}
