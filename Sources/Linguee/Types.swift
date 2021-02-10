import Foundation

public struct TranslationItem: Equatable {
  /// The actual translation.
  public var translation: String
  /// The word types of the translation.
  public var wordTypes: [String]

  public init(
    translation: String,
    wordTypes: [String]
  ) {
    self.translation = translation
    self.wordTypes = wordTypes
  }
}

public struct MainItem: Equatable {
  /// The translated phrase.
  public var phrase: String
  /// The word types of the phrase.
  public var wordTypes: [String]
  /// The link to this item.
  public var link: URL

  public init(
    phrase: String,
    wordTypes: [String],
    link: URL
  ) {
    self.phrase = phrase
    self.wordTypes = wordTypes
    self.link = link
  }
}

public struct Autocompletion: Equatable {
  public var mainItem: MainItem
  public var translations: [TranslationItem]

  public init(
    mainItem: MainItem,
    translations: [TranslationItem]
  ) {
    self.mainItem = mainItem
    self.translations = translations
  }
}
