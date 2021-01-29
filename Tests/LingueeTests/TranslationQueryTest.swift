import Foundation
import XCTest

@testable import Linguee

class TranslationQueryTest: XCTestCase {
  private var query: TranslationQuery!

  override func setUp() {
    super.setUp()
    query = TranslationQuery(text: "hola", languagePair: .testPair, translationDirection: .auto)
  }

  /// Tests that for a lightweight mode the generated url searches with `qe=` query item.
  func testURLWithModeLightweight() {
    XCTAssertEqual(
      query.url(withMode: .lightweight),
      URL(string: "https://www.linguee.com/spanish-italian/search?source=auto&qe=hola"))
  }

  /// Tests that for a regular mode the generated url searches with `query=` query item.
  func testURLWithModeRegular() {
    XCTAssertEqual(
      query.url(withMode: .regular),
      URL(string: "https://www.linguee.com/spanish-italian/search?source=auto&query=hola"))
  }

  /// Tests that for a language pair is taken into account when generating search path.
  func testURLWithLanguagePair() {
    query.languagePair = LanguagePair(source: "german", destination: "english")

    XCTAssertEqual(
      query.url(withMode: .lightweight),
      URL(string: "https://www.linguee.com/german-english/search?source=auto&qe=hola"))
  }

  /// Tests that for a `source` translation direction the `sourceLanguage` is specified as `source=`
  /// query item.
  func testURLWithTranslationDirectionSource() {
    query.translationDirection = .source

    XCTAssertEqual(
      query.url(withMode: .lightweight),
      URL(string: "https://www.linguee.com/spanish-italian/search?source=spanish&qe=hola"))
  }

  /// Tests that for a `destination` translation direction the `destinationLanguage` is specified as
  /// `source=` query item.
  func testURLWithTranslationDirectionDestination() {
    query.translationDirection = .destination

    XCTAssertEqual(
      query.url(withMode: .lightweight),
      URL(string: "https://www.linguee.com/spanish-italian/search?source=italian&qe=hola"))
  }
}
