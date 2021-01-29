import Foundation
import Linguee
import XCTest

@testable import LingueeSearchWorkflow

class DefaultFallbackTest: XCTestCase {

  /// Tests that the fallback prompts the user to search on Linguee and points to a full search
  /// page.
  func testDefaultFallback() {
    let query = TranslationQuery(
      text: "hola", languagePair: LanguagePair(source: "left", destination: "right"),
      translationDirection: .auto)
    let fallback = DefaultFallback(query: query)

    XCTAssertEqual(fallback.text, "Search Linguee for 'hola'")
    XCTAssertEqual(fallback.arg, "https://www.linguee.com/left-right/search?source=auto&query=hola")
  }
}
