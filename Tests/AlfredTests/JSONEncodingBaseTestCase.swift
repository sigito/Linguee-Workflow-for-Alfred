import Foundation
import XCTest

class JSONEncodingBaseTestCase: XCTestCase {
  var encoder: JSONEncoder!

  override func setUpWithError() throws {
    encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
  }

  // MARK: - Helpers

  func encode<T: Encodable>(_ value: T) throws -> String {
    let data = try encoder.encode(value)
    return try XCTUnwrap(String(data: data, encoding: .utf8))
  }
}
