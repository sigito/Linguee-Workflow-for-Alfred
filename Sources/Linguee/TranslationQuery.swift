import Foundation

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

  public init(text: String, languagePair: LanguagePair) {
    self.text = text
    self.languagePair = languagePair
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
      URLQueryItem(name: "source", value: "auto"),
      mode.queryItem(withQuery: text),
    ]
    // TODO: throw an error if the URL creation fails.
    return searchURL.url!
  }
}
