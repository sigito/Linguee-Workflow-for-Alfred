import Alfred
import Foundation
import Linguee
import XCTest

@testable import LingueeSearchWorkflow

class TranslationQuery_EnvironmentTest: XCTestCase {

  /// Tests that the environment based initialization uses values from the environment.
  func testConstructionWithEnvironment() {
    let environment = WorkflowEnvironment(environment: [
      "source_language": "left",
      "destination_language": "right",
    ])
    let text = "queryText"
    let query = TranslationQuery(text: text, environment: environment)

    XCTAssertEqual(query.text, text)
    XCTAssertEqual(query.languagePair, LanguagePair(source: "left", destination: "right"))
  }
}
