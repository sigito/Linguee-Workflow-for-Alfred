import Foundation
import XCTest

@testable import Linguee

fileprivate extension String.Encoding {
  static let isoLatin9 = String.Encoding.init(rawValue: 2147484175)
}

class URLResponse_EncodingTest: XCTestCase {

  /// Tests that the `.utf8` encoding is returned for the `utf-8` encoding name.
  func testUTF8() {
    XCTAssertEqual(response(textEncodingName: "utf-8").textEncoding, .utf8)
  }

  /// Tests that the `.isoLatin9` encoding is returned for the `iso-8859-15` encoding name.
  func testISO_8859_15() {
    XCTAssertEqual(response(textEncodingName: "iso-8859-15").textEncoding, .isoLatin9)
  }

  /// Tests that `nil` is returned if no encoding name is available.
  func testNilForNoEncodingName() {
    XCTAssertNil(response(textEncodingName: nil).textEncoding)
  }

  /// Tests that `nil` is returned if the encoding name is invalid.
  func testNilForBadEncodingName() {
    XCTAssertNil(response(textEncodingName: "not an encoding name").textEncoding)
  }

  // MARK: - Private

  private func response(textEncodingName: String?) -> URLResponse {
    return URLResponse(url: .linguee, mimeType: "text/html", expectedContentLength: 0, textEncodingName: textEncodingName)
  }
}
