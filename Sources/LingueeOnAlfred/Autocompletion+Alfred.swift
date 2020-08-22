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
  return
    translations
    .map { format(phrase: $0.translation, wordTypes: $0.wordTypes) }
    .joined(separator: " · ")
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
    let formattedTitle = format(phrase: self.mainItem.phrase, wordTypes: self.mainItem.wordTypes)
    let formattedTranslations = format(translations: self.translations)
    let resultsURL = self.mainItem.link.absoluteString
    let copyText = self.copyText(
      title: formattedTitle, translations: formattedTranslations, resultsURL: resultsURL)
    let largeType = self.largeType(title: formattedTitle, translations: self.translations)
    return Item(
      title: formattedTitle,
      subtitle: formattedTranslations,
      arg: resultsURL,
      autocomplete: self.mainItem.phrase,
      mods: [.cmd: .defaultFallback(defaultFallback)],
      text: [.copy: copyText, .largeType: largeType],
      quickLookURL: resultsURL)
  }

  private func copyText(title: String, translations: String, resultsURL: String) -> String {
    // Do not add a translations line, if there are no translations found.
    if translations.isEmpty {
      return """
        \(title)

        \(resultsURL)
        """
    }
    return """
      \(title)
      \(translations)

      \(resultsURL)
      """
  }

  private func largeType(title: String, translations: [TranslationItem]) -> String {
    if translations.isEmpty {
      return title
    } else {
      let formattedTranslations =
        translations.map { item in
          let line = format(phrase: item.translation, wordTypes: item.wordTypes)
          return "· \(line)"
        }
        .joined(separator: "\n")
      return """
        \(title)
        \(formattedTranslations)
        """
    }
  }
}
