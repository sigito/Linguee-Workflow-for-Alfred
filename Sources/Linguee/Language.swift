import Foundation

public struct LanguagePair {
  public var source: String
  public var destination: String

  public init(source: String, destination: String) {
    self.source = source
    self.destination = destination
  }
}

extension LanguagePair {
  public static var englishGerman = LanguagePair(source: "english", destination: "german")
}
