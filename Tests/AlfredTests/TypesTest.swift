import Foundation
import XCTest

@testable import Alfred

class TypesTest: JSONEncodingBaseTestCase {

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

  /// Tests that `Item` with `Modifier` is encoded accourding to the format expected by Alfred.
  func testItemWithModifier() throws {
    let item = Item(title: "Title", mods: [.alt: .testModifier])
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

  /// Tests that `Item` with `text` is encoded according to the format expected by Alfred.
  func testTextObject() throws {
    let item = Item(title: "Title", text: [.copy: "Copy text", .largeType: "Large text"])
    let expectedOutput = """
      {
        "text" : {
          "copy" : "Copy text",
          "largetype" : "Large text"
        },
        "title" : "Title",
        "valid" : true
      }
      """
    let encodedItem = try self.encodedJson(item)
    XCTAssertEqual(encodedItem, expectedOutput)
  }

  /// Tests that the `Item.quickLookURL` is encoded with a correct key and value.
  func testQuickLookURL() throws {
    let item = Item(title: "Title", quickLookURL: "https://example.com/")
    let expectedOutput = #"""
      {
        "quicklookurl" : "https:\/\/example.com\/",
        "title" : "Title",
        "valid" : true
      }
      """#
    let encodedItem = try self.encodedJson(item)
    XCTAssertEqual(encodedItem, expectedOutput)
  }

  /// Tests that the `Item.icon` is encoded with a correct key and value.
  func testIcon() throws {
    let item = Item(title: "Title", icon: .fileType(of: "public.png"))
    let expectedOutput = """
      {
        "icon" : {
          "path" : "public.png",
          "type" : "filetype"
        },
        "title" : "Title",
        "valid" : true
      }
      """

    XCTAssertEqual(try encode(item), expectedOutput)
  }

  /// MARK: - Private

  /// Returns a string with an JSON-encoded `value`.
  private func encodedJson<T>(_ value: T) throws -> String where T: Encodable {
    let data = try self.encoder.encode(value)
    return try XCTUnwrap(String(data: data, encoding: .utf8))
  }
}
