@testable import Linguee

import Foundation
import SwiftSoup
import XCTest

final class Types_SwiftSoupTest: XCTestCase {

  func testParseAutocompletionItem() throws {
    let html = """
      <div class='autocompletion_item sourceIsLang1 isForeignTerm'>
        <div class='main_row'>
          <div class='main_item' lid='DE:Beobachten32806' lc='DE' href='/german-english/translation/Beobachten.html'>
            Beobachten
          </div>
          <div class='main_wordtype' wt='105'>
            nt
          </div>
        </div>
        <div class='translation_row line singleline'>
          <div>
            <div class='translation_item' bid='10000313746'  lid='EN:observation46431'>
              observation
              <div class='wordtype' wt='100'>
                n
              </div>
            </div>
            &#8203;
          </div>
        </div>
      </div>
    """
    let element = try SwiftSoup.parseBodyFragment(html).select("html > body > div.autocompletion_item").first()!
    let expectedautocompletion =
      Autocompletion(
        mainItem: MainItem(
          phrase: "Beobachten",
          wordTypes: ["nt"],
          link: URL(string: "https://www.linguee.com/german-english/translation/Beobachten.html")!
        ),
        translations: [
          TranslationItem(translation: "observation", wordTypes: ["n"])
        ])

    let autocompletion = try Autocompletion.from(autocompletionItem: element)

    XCTAssertEqual(autocompletion, expectedautocompletion)
  }

  static var allTests = [
    ("testParseAutocompletionItem", testParseAutocompletionItem),
  ]
}
