import CommonTesting
import Foundation
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
    query = TranslationQuery(text: "hola", languagePair: .testPair)
  }

  /// Tests that a search is done using a valid search URL.
  func testSearchURL() {
    var requestURL: URL?
    loader.stubs.requestDataResult = { url in
      requestURL = url
      return .success((Data(), URLResponse()))
    }

    let _ = linguee.search(for: query).subscribe(translationSubscriber)

    translationSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(
      requestURL, URL(string: "https://www.linguee.com/spanish-italian/search?source=auto&qe=hola"))
  }
}
