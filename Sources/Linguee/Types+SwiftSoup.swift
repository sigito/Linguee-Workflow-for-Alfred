import Foundation
import SwiftSoup

fileprivate enum ClassPrefix: String {
  case main = "main_"
  case none = ""
}

fileprivate func parseWordTypes(in element: Element, classPrefix: ClassPrefix) throws -> [String] {
  return try
    element
    .select("div.\(classPrefix.rawValue)wordtype")
    // Drop word types without text.
    .filter { $0.hasText() }  // TODO: add a test for empty word types.
    .map { $0.ownText() }
}

extension TranslationItem {
  static func from(_ element: Element) throws -> Self {
    guard try element.classNames().contains("translation_item") else {
      preconditionFailure("Expected translation_item class: \(element)")
    }
    return self.init(
      translation: element.ownText(),
      wordTypes: try parseWordTypes(in: element, classPrefix: .none)
    )
  }
}

extension MainItem {
  static func from(mainRow: Element) throws -> Self {
    guard try mainRow.classNames().contains(where: { ["main_row", "suggest_row"].contains($0) })
    else {
      preconditionFailure("Expected main_row class: \(mainRow)")
    }
    guard let mainItem = try mainRow.select("div.main_item").first() else {
      fatalError("Main item element not found in \(mainRow)")
    }
    let wordTypes = try parseWordTypes(in: mainRow, classPrefix: .main)
    let href = try mainItem.attr("href")
    guard let url = URL.linguee(href)?.absoluteURL else {
      fatalError("'href' attribute content is not a URL: \(href)")
    }

    return self.init(
      phrase: mainItem.ownText(),
      wordTypes: wordTypes,
      link: url)
  }
}

extension Autocompletion {
  static func from(autocompletionItem: Element) throws -> Self {
    guard try autocompletionItem.classNames().contains("autocompletion_item") else {
      preconditionFailure("Expected autocompletion_item class: \(autocompletionItem)")
    }
    // TODO: test div.suggest_row
    guard let mainRowElement = try autocompletionItem.select("div.main_row,div.suggest_row").first()
    else {
      fatalError("Main row element not found in \(autocompletionItem)")
    }
    let mainItem = try MainItem.from(mainRow: mainRowElement)
    let translations = try autocompletionItem.select(
      "div.translation_row > div > div.translation_item"
    )
    .map { try TranslationItem.from(_: $0) }
    return self.init(mainItem: mainItem, translations: translations)
  }
}
