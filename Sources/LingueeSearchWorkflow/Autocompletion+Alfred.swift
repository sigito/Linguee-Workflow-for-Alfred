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

extension Modifier {
  static func defaultFallback(_ fallback: DefaultFallback) -> Self {
    return .init(subtitle: fallback.text, arg: fallback.arg)
  }
}

extension Item {
  static func fromDefaultFallback(_ fallback: DefaultFallback) -> Self {
    return .init(
      title: fallback.text,
      arg: fallback.arg,
      icon: .linguee)
  }
}

extension Autocompletion {
  // TODO: generalize item creation logic in a protocol.
  func alfredItem(defaultFallback: DefaultFallback, promote: Bool) -> Item {
    let formattedTitle = format(phrase: self.mainItem.phrase, wordTypes: self.mainItem.wordTypes)
    let formattedTranslations = format(translations: self.translations)
    let resultsURL = self.mainItem.link.absoluteString
    let copyText = self.copyText(
      title: formattedTitle, translations: formattedTranslations, resultsURL: resultsURL,
      promote: promote)
    let largeType = self.largeType(title: formattedTitle, translations: self.translations)
    return Item(
      title: formattedTitle,
      subtitle: formattedTranslations,
      arg: resultsURL,
      icon: .checkMark,
      autocomplete: self.mainItem.phrase,
      mods: [.cmd: .defaultFallback(defaultFallback)],
      text: [.copy: copyText, .largeType: largeType],
      quickLookURL: resultsURL)
  }

  private func copyText(title: String, translations: String, resultsURL: String, promote: Bool)
    -> String
  {
    var baseText: String
    if translations.isEmpty {
      // Do not add a translations line, if there are no translations found.
      baseText = """
        \(title)

        \(resultsURL)
        """
    } else {
      baseText = """
        \(title)
        \(translations)

        \(resultsURL)
        """
    }

    if promote {
      let promotionText =
        "\n\nTranslated using Linguee Workflow (https://tinyurl.com/LingueeWorkflow)."
      baseText.append(promotionText)
    }
    return baseText
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
