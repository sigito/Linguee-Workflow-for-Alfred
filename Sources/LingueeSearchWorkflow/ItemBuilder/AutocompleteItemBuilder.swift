import Alfred
import Linguee

extension DefaultFallback {
  fileprivate var modifier: Modifier {
    return Modifier(subtitle: text, valid: true, arg: arg)
  }
}

/// A builder to construct an item instance for the autocompletion.
class AutocompleteItemBuilder {
  let autocompletion: Autocompletion
  let fallback: DefaultFallback
  let copyTextPromotion: Bool

  init(_ autocompletion: Autocompletion, fallback: DefaultFallback, copyTextPromotion: Bool) {
    self.autocompletion = autocompletion
    self.fallback = fallback
    self.copyTextPromotion = copyTextPromotion
  }

  /// Returns an item for the `autocompletion`.
  var item: Item {
    return Item(
      title: formattedMainItem,
      subtitle: formattedTranslations.joined(separator: " · "),
      arg: resultsURL,
      icon: .checkMark,
      autocomplete: autocompletion.mainItem.phrase,
      mods: [.cmd: fallback.modifier],
      text: [.copy: copyText(), .largeType: largeType()],
      quickLookURL: resultsURL)
  }

  // MARK: - Private

  /// The formatted main item.
  private lazy var formattedMainItem = format(
    phrase: autocompletion.mainItem.phrase, wordTypes: autocompletion.mainItem.wordTypes)

  /// The formatted translations.
  private lazy var formattedTranslations: [String] = autocompletion.translations.map {
    translation in
    return self.format(phrase: translation.translation, wordTypes: translation.wordTypes)
  }

  /// The URL string to the translation page.
  private var resultsURL: String {
    return autocompletion.mainItem.link.absoluteString
  }

  /// Returns text to be used for the copy action.
  private func copyText() -> String {
    var baseText: String
    if self.formattedTranslations.isEmpty {
      // Do not add a translations line, if there are no translations found.
      baseText = """
        \(formattedMainItem)

        \(resultsURL)
        """
    } else {
      baseText = """
        \(formattedMainItem)
        \(formattedTranslations.joined(separator: ", "))

        \(resultsURL)
        """
    }

    if copyTextPromotion {
      let promotionText =
        "\n\nTranslated using Linguee Workflow (https://tinyurl.com/LingueeWorkflow)."
      baseText.append(promotionText)
    }
    return baseText
  }

  /// Returns text to be displayed in large type.
  private func largeType() -> String {
    if formattedTranslations.isEmpty {
      return formattedMainItem
    } else {
      let translationsList =
        formattedTranslations
        .map { "· \($0)" }
        .joined(separator: "\n")
      return """
        \(formattedMainItem)
        \(translationsList)
        """
    }
  }

  /// Returns `translations` in format "<phrase> (<wordType>/<wordType>/...)" and joined with " · ".
  private func format(translations: [TranslationItem]) -> String {
    return
      translations
      .map { format(phrase: $0.translation, wordTypes: $0.wordTypes) }
      .joined(separator: " · ")
  }

  /// Returns the title in format "<phrase> (<wordType>/<wordType>/...)".
  private func format(phrase: String, wordTypes: [String]) -> String {
    guard !wordTypes.isEmpty else {
      return phrase
    }
    return "\(phrase) (\(wordTypes.joined(separator: "/")))"
  }

}
