import Foundation
import SwiftSoup

extension TranslationItem {
  static func from(_ element: Element) throws -> Self {
    guard try element.classNames().contains("translation_item") else {
      preconditionFailure("Expected translation_item class: \(element)")
    }
    let phrase = element.ownText()
    let wordTypes = try element.select("div.wordtype").map { $0.ownText() }
    return self.init(translation: phrase, wordTypes: wordTypes)
  }
}

extension MainItem {
  static func from(mainRow: Element) throws -> Self {
    guard try mainRow.classNames().contains("main_row") else {
      preconditionFailure("Expected main-item class: \(mainRow)")
    }
    guard let mainItem = try mainRow.select("div.main_item").first() else {
      fatalError("Main item element not found in \(mainRow)")
    }
    let wordTypes = try mainRow.select("div.main_wordtype").map { $0.ownText() }
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
    guard let mainRowElement = try autocompletionItem.select("div.main_row").first() else {
      fatalError("Main row element not found in \(autocompletionItem)")
    }
    let mainItem = try MainItem.from(mainRow: mainRowElement)
    let translations = try autocompletionItem.select("div.translation_row > div > div.translation_item")
      .map { try TranslationItem.from(_: $0) }
    return self.init(mainItem: mainItem, translations: translations)
  }
}
