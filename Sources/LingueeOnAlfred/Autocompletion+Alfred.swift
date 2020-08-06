import Alfred
import Linguee

/// Returns the title in format "Beobachten (n/...)".
fileprivate func format(phrase: String, wordTypes: [String]) -> String {
  return "\(phrase) (\(wordTypes.joined(separator: "/")))"
}

fileprivate func format(translations: [TranslationItem]) -> String {
  return translations.map { format(phrase: $0.translation, wordTypes: $0.wordTypes) }.joined(separator: " · ")
}

extension Autocompletion {
  var alfredItem: Item {
    return Item(title: format(phrase: self.mainItem.phrase, wordTypes: self.mainItem.wordTypes),
                subtitle: format(translations: self.translations),
                arg: self.mainItem.link.absoluteString)
  }
}
