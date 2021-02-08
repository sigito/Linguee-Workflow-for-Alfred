import Alfred
import CommonTesting
import Linguee
import LingueeTestData
import Updater
import XCTest

@testable import LingueeSearchWorkflow

fileprivate enum TestError: Error {
  case returnMeMaybe
}

class AlfredItemBuilderTest: JSONEncodingBaseTestCase {
  private var builder: AlfredItemBuilder!

  override func setUpWithError() throws {
    try super.setUpWithError()
    let environment = WorkflowEnvironmentBuilder().environment
    builder = AlfredItemBuilder(query: .bereich, environment: environment)
  }

  /// Tests that the autocompletion item has all the metadata.
  func testAutocompletionItem() {
    let item = builder.item(for: .bereich)

    XCTAssertEqual(
      try json(for: item),
      #"""
      {
        "arg" : "https:\/\/www.linguee.com\/german-english\/translation\/Bereich.html",
        "autocomplete" : "Bereich",
        "icon" : {
          "path" : ".\/check.png"
        },
        "mods" : {
          "cmd" : {
            "arg" : "https:\/\/www.linguee.com\/english-german\/search?source=auto&query=bereich",
            "subtitle" : "Search Linguee for 'bereich'",
            "valid" : true
          }
        },
        "quicklookurl" : "https:\/\/www.linguee.com\/german-english\/translation\/Bereich.html",
        "subtitle" : "area (n) · field (n) · group (n) · sector (n)",
        "text" : {
          "copy" : "Bereich (m)\narea (n), field (n), group (n), sector (n)\n\nhttps:\/\/www.linguee.com\/german-english\/translation\/Bereich.html\n\nTranslated using Linguee Workflow (https:\/\/tinyurl.com\/LingueeWorkflow).",
          "largetype" : "Bereich (m)\n· area (n)\n· field (n)\n· group (n)\n· sector (n)"
        },
        "title" : "Bereich (m)",
        "valid" : true
      }
      """#)
  }

  /// Tests that the error item includes the available details.
  func testErrorItem() {
    let item = builder.item(for: TestError.returnMeMaybe)

    XCTAssertEqual(
      try json(for: item),
      #"""
      {
        "icon" : {
          "path" : ".\/warning.png"
        },
        "subtitle" : "Details: returnMeMaybe",
        "title" : "Failed to get translations!",
        "valid" : false
      }
      """#)
  }

  /// Tests that the release item downloads the workflow on the default action, and goes to the
  /// release page on a secondary one.
  func testReleaseItem() {
    let release = Release(
      version: "1.2.3", workflowURL: URL(string: "https://example.com/release/workflow")!,
      releaseURL: URL(string: "https://example.com/release")!,
      releaseDate: Date())
    let item = builder.item(for: release)

    XCTAssertEqual(
      try json(for: item),
      #"""
      {
        "arg" : "https:\/\/example.com\/release\/workflow",
        "icon" : {
          "path" : ".\/update.png"
        },
        "mods" : {
          "cmd" : {
            "arg" : "https:\/\/example.com\/release",
            "subtitle" : "Open the 1.2.3 release page",
            "valid" : true
          }
        },
        "subtitle" : "Update to version 1.2.3.",
        "text" : {
          "copy" : "https:\/\/example.com\/release"
        },
        "title" : "An update for Linguee Search is available.",
        "valid" : true
      }
      """#)
  }

  /// Tests that the builder returns an item that opens the query search on Linguee website.
  func testOpenSearchOnLingueeItem() {
    let item = builder.openSearchOnLingueeItem()

    XCTAssertEqual(
      try json(for: item),
      #"""
      {
        "arg" : "https:\/\/www.linguee.com\/english-german\/search?source=auto&query=bereich",
        "icon" : {
          "path" : ".\/linguee.png"
        },
        "title" : "Search Linguee for 'bereich'",
        "valid" : true
      }
      """#)
  }
}
