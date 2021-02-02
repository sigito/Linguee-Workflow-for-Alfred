import Foundation
import Linguee

extension LanguagePair {
  public static let testPair = LanguagePair(source: "spanish", destination: "italian")
}

extension MainItem {
  static let bereich = MainItem(
    phrase: "Bereich", wordTypes: ["m"],
    link: URL(string: "https://www.linguee.com/german-english/translation/Bereich.html")!)
}

extension Array where Element == TranslationItem {
  static let bereich = [
    TranslationItem(translation: "area", wordTypes: ["n"]),
    TranslationItem(translation: "field", wordTypes: ["n"]),
    TranslationItem(translation: "group", wordTypes: ["n"]),
    TranslationItem(translation: "sector", wordTypes: ["n"]),
  ]
}

extension Autocompletion {
  static let bereich = Autocompletion(
    mainItem: .bereich, translations: .bereich)

  static var bereichData: Data {
    let url = Bundle.module.url(forResource: "bereich-translation-response", withExtension: "html")!
    return try! Data(contentsOf: url)
  }
}
