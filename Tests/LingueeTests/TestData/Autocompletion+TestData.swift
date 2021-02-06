import Foundation
import Linguee

extension LanguagePair {
  public static let spanishItalian = LanguagePair(source: "spanish", destination: "italian")
}

extension MainItem {
  public static let bereich = MainItem(
    phrase: "Bereich", wordTypes: ["m"],
    link: URL(string: "https://www.linguee.com/german-english/translation/Bereich.html")!)
}

extension Array where Element == TranslationItem {
  public static let bereich = [
    TranslationItem(translation: "area", wordTypes: ["n"]),
    TranslationItem(translation: "field", wordTypes: ["n"]),
    TranslationItem(translation: "group", wordTypes: ["n"]),
    TranslationItem(translation: "sector", wordTypes: ["n"]),
  ]
}

extension Autocompletion {
  public static let bereich = Autocompletion(mainItem: .bereich, translations: .bereich)
}

extension TranslationQuery {
  public static let hola = TranslationQuery(text: "hola", languagePair: .spanishItalian)
  public static let bereich = TranslationQuery(text: "bereich", languagePair: .englishGerman)
}
