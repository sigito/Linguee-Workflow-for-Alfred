import CommonTesting
import Foundation
import LingueeTestData
import XCTest

@testable import Linguee

class LingueeTest: XCTestCase {
  private var loader: URLLoaderFake!
  private var linguee: Linguee!
  private var query: TranslationQuery!

  override func setUp() {
    super.setUp()
    loader = URLLoaderFake()
    linguee = Linguee(loader: loader)
  }

  /// Tests that a search is done using a valid search URL.
  func testSearchURL() async throws {
    var requestURL: URL?
    loader.stubs.requestDataResult = { url in
      requestURL = url
      return (Data(), URLResponse())
    }

    let _ = try await linguee.search(for: .holaEsIt)

    XCTAssertEqual(
      requestURL, URL(string: "https://www.linguee.com/spanish-italian/search?source=auto&qe=hola"))
  }

  /// Tests html data decoding when the response encoding name is `utf-8`.
  func testUTF8Encoding() async throws {
    loader.stubs.requestDataResult = { url in
      let response = URLResponse(
        url: url, mimeType: "text/html", expectedContentLength: 0, textEncodingName: "utf-8")
      return (.helloEnJpData, response)
    }

    let result = try await linguee.search(for: .helloEnJp)

    XCTAssertEqual(result.first, .helloEnJp)
  }

  /// Tests html data decoding when the response encoding name is `iso-8859-15`.
  func testISO_8859_15Encoding() async throws {
    loader.stubs.requestDataResult = { url in
      let response = URLResponse(
        url: url, mimeType: "text/html", expectedContentLength: 0, textEncodingName: "iso-8859-15")
      return (.bereichEnDeData, response)
    }

    let result = try await linguee.search(for: .helloEnJp)

    XCTAssertEqual(result.first, .bereichDeEn)
  }
}
