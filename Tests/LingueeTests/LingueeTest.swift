import CommonTesting
import Foundation
import XCTest

@testable import Linguee

class LingueeTest: XCTestCase {
  private var loader: URLLoaderFake!
  private var linguee: Linguee!
  private let translationSubscriber = TestSubscriber<[Autocompletion], Linguee.Error>()

  override func setUp() {
    super.setUp()
    loader = URLLoaderFake()
    linguee = Linguee(loader: loader)
  }

  /// Tests that a search is done against a valid search URL.
  func testSearchURL() {
    var requestURL: URL?
    loader.stubs.requestDataResult = { url in
      requestURL = url
      return .success((Data(), URLResponse()))
    }

    let _ = linguee.search(for: "hello").subscribe(translationSubscriber)

    translationSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(
      requestURL, URL(string: "https://www.linguee.com/english-german/search?source=auto&qe=hello"))
  }

  /// Tests that a search is done for the provided language pair.
  func testSearchBasedOnTheLanguagePair() {
    var requestURL: URL?
    loader.stubs.requestDataResult = { url in
      requestURL = url
      return .success((Data(), URLResponse()))
    }

    let languagePair = LanguagePair(source: "italian", destination: "ukrainian")
    linguee = Linguee(languagePair: languagePair, loader: loader)
    let _ = linguee.search(for: "hello")
      .subscribe(translationSubscriber)

    translationSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(
      requestURL,
      URL(string: "https://www.linguee.com/italian-ukrainian/search?source=auto&qe=hello"))
  }
}
