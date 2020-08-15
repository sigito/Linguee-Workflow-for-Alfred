import Alfred
import Foundation
import Linguee

/// Returns the title in format "Beobachten (n/...)".
fileprivate func format(phrase: String, wordTypes: [String]) -> String {
  guard !wordTypes.isEmpty else {
    return phrase
  }
  return "\(phrase) (\(wordTypes.joined(separator: "/")))"
}

fileprivate func format(translations: [TranslationItem]) -> String {
  return translations.map { format(phrase: $0.translation, wordTypes: $0.wordTypes) }.joined(separator: " · ")
}

struct DefaultFallback {
  let text: String
  let arg: String

  init(query: String) {
    // Trim the query to be used in a direct search link.
    let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
    let searchURL = Linguee.searchURL(query: trimmedQuery)
    self.text = "Search Linguee for '\(trimmedQuery)'"
    self.arg = searchURL.absoluteString
  }
}

extension Modifier {
  static func defaultFallback(_ fallback: DefaultFallback) -> Self {
    return .init(subtitle: fallback.text, arg: fallback.arg)
  }
}

extension Item {
  static func fromDefaultFallback(_ fallback: DefaultFallback) -> Self {
    return .init(title: fallback.text, arg: fallback.arg)
  }
}

extension Autocompletion {
  func alfredItem(defaultFallback: DefaultFallback) -> Item {
    return Item(title: format(phrase: self.mainItem.phrase, wordTypes: self.mainItem.wordTypes),
                subtitle: format(translations: self.translations),
                arg: self.mainItem.link.absoluteString,
                autocomplete: self.mainItem.phrase,
                mods: .cmd(.defaultFallback(defaultFallback)))
  }
}
