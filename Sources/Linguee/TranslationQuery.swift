import Foundation

/// Indicates the direction of the translation lookup.
public enum TranslationDirection: String {
  /// Translate from the source language only.
  case source
  /// Translate from the desctination language only.
  case destination
  /// Automatically choose correct language to traslate from. In case the query can be translated
  /// form either of the languages, the result would contain translations from both languages.
  case auto
}

extension TranslationDirection {
  fileprivate func queryItem(for languagePair: LanguagePair) -> URLQueryItem {
    switch self {
    case .auto:
      return URLQueryItem(name: "source", value: "auto")
    case .source:
      return URLQueryItem(name: "source", value: languagePair.source)
    case .destination:
      return URLQueryItem(name: "source", value: languagePair.destination)
    }
  }
}

public enum QueryMode: String {
  /// No CSS payload.
  case lightweight = "qe"
  /// Regular website.
  case regular = "query"
}

extension QueryMode {
  fileprivate func queryItem(withQuery query: String) -> URLQueryItem {
    return URLQueryItem(name: self.rawValue, value: query)
  }
}

extension LanguagePair {
  fileprivate var lingueePath: String {
    return "\(source)-\(destination)"
  }
}

/// The translation query configuration.
public struct TranslationQuery {
  /// The text to be translated.
  public var text: String
  /// The language pair to be used for translation.
  public var languagePair: LanguagePair
  /// The direction of the translation.
  public var translationDirection: TranslationDirection

  public init(
    text: String,
    languagePair: LanguagePair,
    translationDirection: TranslationDirection
  ) {
    self.text = text
    self.languagePair = languagePair
    self.translationDirection = translationDirection
  }
}

extension TranslationQuery {

  /// Returns a URL to search for `text` using `languagePair` on Linguee.
  /// `mode` specifies if the query URL should point at a website version with stripped CSS,
  /// or to a regular full-blown version.
  public func url(withMode mode: QueryMode) -> URL {
    var searchURL = URLComponents(url: .linguee, resolvingAgainstBaseURL: false)!
    searchURL.path = "/\(languagePair.lingueePath)/search"
    searchURL.queryItems = [
      translationDirection.queryItem(for: languagePair),
      mode.queryItem(withQuery: text),
    ]
    // TODO: throw an error if the URL creation fails.
    return searchURL.url!
  }
}
