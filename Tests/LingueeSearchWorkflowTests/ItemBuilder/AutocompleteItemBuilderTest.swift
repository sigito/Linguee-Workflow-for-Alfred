import CommonTesting
import Foundation
import Linguee
import LingueeTestData
import XCTest

@testable import LingueeSearchWorkflow

class AutocompleteItemBuilderTest: JSONEncodingBaseTestCase {

  /// Tests tha the copy text has format of a query followed by comman-separated translations and a
  /// link to Linguee page.
  func testCopyText() throws {
    let item = AutocompleteItemBuilder(
      .bereich, fallback: .bereich, copyBehavior: .all
    ).item

    let copyText = try XCTUnwrap(item.text?.copy)
    XCTAssertEqual(
      copyText,
      """
      Bereich (m)
      area (n), field (n), group (n), sector (n)

      https://www.linguee.com/german-english/translation/Bereich.html
      """)
  }

  /// Tests that the copy text includes a link to the linguee workflow when the promotion is
  /// enabled.
  func testCopyTextPromotion() throws {
    let item = AutocompleteItemBuilder(
      .bereich, fallback: .bereich, copyBehavior: .allWithPromotion
    ).item

    let copyText = try XCTUnwrap(item.text?.copy)
    XCTAssertEqual(
      copyText,
      """
      Bereich (m)
      area (n), field (n), group (n), sector (n)

      https://www.linguee.com/german-english/translation/Bereich.html

      Translated using Linguee Workflow (https://tinyurl.com/LingueeWorkflow).
      """)
  }

  /// Tests that the copy text does include translations line if there are no translations
  /// available.
  func testCopyTextWithoutTranslations() throws {
    let autocompletionWithoutTranslations: Autocompletion = {
      var bereich = Autocompletion.bereich
      bereich.translations = []
      return bereich
    }()
    let item = AutocompleteItemBuilder(
      autocompletionWithoutTranslations, fallback: .bereich, copyBehavior: .all
    ).item

    let copyText = try XCTUnwrap(item.text?.copy)
    XCTAssertEqual(
      copyText,
      """
      Bereich (m)

      https://www.linguee.com/german-english/translation/Bereich.html
      """)
  }

  /// Tests that the copy text for `url` copy behavior includes only the translation page URL.
  func testCopyURL() throws {
    let item = AutocompleteItemBuilder(.bereich, fallback: .bereich, copyBehavior: .url).item

    let copyText = try XCTUnwrap(item.text?.copy)
    XCTAssertEqual(copyText, "https://www.linguee.com/german-english/translation/Bereich.html")
  }

  /// Tests that the copy text for `firstTranlationOnly` copy behavior includes only the first
  /// translation.
  func testCopyFirstTranslationOnly() throws {
    let item = AutocompleteItemBuilder(
      .bereich, fallback: .bereich, copyBehavior: .firstTranlationOnly
    ).item

    let copyText = try XCTUnwrap(item.text?.copy)
    XCTAssertEqual(copyText, "area")
  }

  /// Tests that the copy text for `firstTranlationOnly` copy behavior, when there are no
  /// translations, includes the initial query text.
  func testCopyFirstTranslationOnlyWithoutTranlations() throws {
    let autocompletionWithoutTranslations: Autocompletion = {
      var bereich = Autocompletion.bereich
      bereich.translations = []
      return bereich
    }()
    let item = AutocompleteItemBuilder(
      autocompletionWithoutTranslations, fallback: .bereich, copyBehavior: .firstTranlationOnly
    ).item

    let copyText = try XCTUnwrap(item.text?.copy)
    XCTAssertEqual(copyText, "Bereich")
  }

  /// Tests tha the large type text has format of a query followed by the translations list.
  func testLargeType() throws {
    let item = AutocompleteItemBuilder(.bereich, fallback: .bereich, copyBehavior: .all).item

    let largeTypeText = try XCTUnwrap(item.text?.largeType)
    XCTAssertEqual(
      largeTypeText,
      """
      Bereich (m)
      · area (n)
      · field (n)
      · group (n)
      · sector (n)
      """)
  }

  /// Tests that teh large type text contains the query only when there are no translations.
  func testLargeTypeWithoutTranslations() throws {
    let autocompletionWithoutTranslations: Autocompletion = {
      var bereich = Autocompletion.bereich
      bereich.translations = []
      return bereich
    }()
    let item = AutocompleteItemBuilder(
      autocompletionWithoutTranslations, fallback: .bereich, copyBehavior: .all
    ).item

    let largeTypeText = try XCTUnwrap(item.text?.largeType)
    XCTAssertEqual(largeTypeText, "Bereich (m)")
  }
}
