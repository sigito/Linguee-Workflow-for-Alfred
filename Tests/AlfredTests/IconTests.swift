import CommonTesting
import Foundation
import XCTest

@testable import Alfred

class IconTests: JSONEncodingBaseTestCase {

  /// Tests that an `Icon.icon(location:)` is encoded with path and without any type.
  func testIconLocationEncoding() throws {
    let path = Icon.icon(location: "my-icon.png")
    let expectedOutput = """
      {
        "path" : "my-icon.png"
      }
      """

    XCTAssertEqual(try json(for: path), expectedOutput)
  }

  /// Tests that an `Icon.fileIcon(forPath:)` is encoded with the specified path and "fileicon"
  /// type.
  func testFileIconEncoding() throws {
    let path = Icon.fileIcon(forPath: "~/Downloads")
    let expectedOutput = #"""
      {
        "path" : "~\/Downloads",
        "type" : "fileicon"
      }
      """#

    XCTAssertEqual(try json(for: path), expectedOutput)
  }

  /// Tests that an `Icon.fileType(of:)` is encoded with the specfied file and "filetype" type.
  func testaPathEncoding() throws {
    let path = Icon.fileType(of: "public.png")
    let expectedOutput = """
      {
        "path" : "public.png",
        "type" : "filetype"
      }
      """

    XCTAssertEqual(try json(for: path), expectedOutput)
  }
}
