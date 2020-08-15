@testable import Alfred

import Foundation
import XCTest

class TypesTest : XCTestCase {
  private var encoder: JSONEncoder!

  override func setUp() {
    self.encoder = JSONEncoder()
    self.encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
  }

  /// Tests that `Modifier` is serialized into an Alfred-expected format.
  func testModifierSerialization() throws {
    let modifier = Modifier.testModifier
    let expectedOutput = #"""
    {
      "arg" : "https:\/\/example.com\/",
      "subtitle" : "Open example",
      "valid" : true
    }
    """#

    let encodedModifier = try self.encodedJson(modifier)
    XCTAssertEqual(encodedModifier, expectedOutput)
  }

  /// Tests that `Item` with `Modifier` is encoded accourding in a format expected by Alfred.
  func testItemWithModifier() throws {
    let item = Item(title: "Title", mods: .alt(.testModifier))
    let expectedOutput = #"""
    {
      "mods" : {
        "alt" : {
          "arg" : "https:\/\/example.com\/",
          "subtitle" : "Open example",
          "valid" : true
        }
      },
      "title" : "Title",
      "valid" : true
    }
    """#

    let encodedItem = try self.encodedJson(item)
    XCTAssertEqual(encodedItem, expectedOutput)
  }

  /// MARK: - Private

  private func encodedJson<T>(_ value: T) throws -> String where T : Encodable {
    let data = try self.encoder.encode(value)
    return try XCTUnwrap(String(data: data, encoding: .utf8))
  }
}
