import Foundation
import Linguee

extension LanguagePair {
  public static let spanishItalian = LanguagePair(source: "spanish", destination: "italian")
  public static let englishJapanese = LanguagePair(source: "english", destination: "japanese")
}

extension MainItem {
  public static let bereichDeEn = MainItem(
    phrase: "Bereich", wordTypes: ["m"],
    link: URL(string: "https://www.linguee.com/german-english/translation/Bereich.html")!)

  public static let helloEnJp = MainItem(
    phrase: "hello", wordTypes: [],
    link: URL(string: "https://www.linguee.com/english-japanese/translation/hello.html")!)
}

extension Array where Element == TranslationItem {
  public static let bereichEn = [
    TranslationItem(translation: "area", wordTypes: ["n"]),
    TranslationItem(translation: "field", wordTypes: ["n"]),
    TranslationItem(translation: "group", wordTypes: ["n"]),
    TranslationItem(translation: "sector", wordTypes: ["n"]),
  ]

  public static let helloJp = [
    TranslationItem(translation: "ハロー", wordTypes: []),
    TranslationItem(translation: "ニーハオ", wordTypes: []),
    TranslationItem(translation: "今日は", wordTypes: []),
    TranslationItem(translation: "アニョハセヨ", wordTypes: []),
  ]
}

extension Autocompletion {
  public static let bereichDeEn = Autocompletion(mainItem: .bereichDeEn, translations: .bereichEn)
  public static let helloEnJp = Autocompletion(mainItem: .helloEnJp, translations: .helloJp)
}

extension TranslationQuery {
  public static let holaEsIt = TranslationQuery(text: "hola", languagePair: .spanishItalian)
  public static let bereichDeEn = TranslationQuery(text: "bereich", languagePair: .englishGerman)
  public static let helloEnJp = TranslationQuery(text: "hello", languagePair: .englishJapanese)
}
