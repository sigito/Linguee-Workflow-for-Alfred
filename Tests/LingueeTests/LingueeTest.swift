import CommonTesting
import Foundation
import LingueeTestData
import XCTest

@testable import Linguee

class LingueeTest: XCTestCase {
  private var loader: URLLoaderFake!
  private var linguee: Linguee!
  private let translationSubscriber = TestSubscriber<[Autocompletion], Linguee.Error>()
  private var query: TranslationQuery!

  override func setUp() {
    super.setUp()
    loader = URLLoaderFake()
    linguee = Linguee(loader: loader)
  }

  /// Tests that a search is done using a valid search URL.
  func testSearchURL() {
    var requestURL: URL?
    loader.stubs.requestDataResult = { url in
      requestURL = url
      return .success((Data(), URLResponse()))
    }

    let _ = linguee.search(for: .holaEsIt).subscribe(translationSubscriber)

    translationSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(
      requestURL, URL(string: "https://www.linguee.com/spanish-italian/search?source=auto&qe=hola"))
  }

  /// Tests html data decoding when the response encoding name is `utf-8`.
  func testUTF8Encoding() throws {
    loader.stubs.requestDataResult = { url in
      let response = URLResponse(
        url: url, mimeType: "text/html", expectedContentLength: 0, textEncodingName: "utf-8")
      return .success((.helloEnJpData, response))
    }

    let _ = linguee.search(for: .helloEnJp).subscribe(translationSubscriber)
    translationSubscriber.waitForCompletion()!.assertSuccess()

    let result = try XCTUnwrap(translationSubscriber.receivedValues.first)
    let firstResult = try XCTUnwrap(result.first)
    XCTAssertEqual(firstResult, .helloEnJp)
  }

  /// Tests html data decoding when the response encoding name is `iso-8859-15`.
  func testISO_8859_15Encoding() throws {
    loader.stubs.requestDataResult = { url in
      let response = URLResponse(
        url: url, mimeType: "text/html", expectedContentLength: 0, textEncodingName: "iso-8859-15")
      return .success((.bereichEnDeData, response))
    }

    let _ = linguee.search(for: .helloEnJp).subscribe(translationSubscriber)
    translationSubscriber.waitForCompletion()!.assertSuccess()

    let result = try XCTUnwrap(translationSubscriber.receivedValues.first)
    let firstResult = try XCTUnwrap(result.first)
    XCTAssertEqual(firstResult, .bereichDeEn)
  }
}
