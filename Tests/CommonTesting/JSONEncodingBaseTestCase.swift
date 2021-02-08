import Foundation
import XCTest

open class JSONEncodingBaseTestCase: XCTestCase {
  var encoder: JSONEncoder!

  open override func setUpWithError() throws {
    encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
  }

  // MARK: - Helpers

  public func json<T: Encodable>(for value: T) throws -> String {
    let data = try encoder.encode(value)
    return try XCTUnwrap(String(data: data, encoding: .utf8))
  }
}
