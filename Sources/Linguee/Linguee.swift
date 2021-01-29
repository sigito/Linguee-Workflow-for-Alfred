import Combine
import Common
import Foundation
import SwiftSoup

enum LingueeQueryMode: String {
  /// No CSS payload.
  case lightweight = "qe"
  /// Regular website.
  case regular = "query"
}

extension LanguagePair {
  fileprivate var lingueePath: String {
    return "\(source)-\(destination)"
  }
}

extension URL {

  static let linguee = URL(string: "https://www.linguee.com")!

  private static let sourceQueryItem = URLQueryItem(name: "source", value: "auto")

  static func linguee(_ href: String) -> URL? {
    return URL(string: href, relativeTo: .linguee)
  }

  /// Returns a URL to search for `query` on Linguee.
  /// `mode` specifies if the query URL should point at a website version with stripped CSS,
  /// or to a regular full-blown version.
  static func linqueeSearch(_ query: String, mode: LingueeQueryMode, languagePair: LanguagePair)
    -> URL
  {
    var searchURL = URLComponents(url: URL.linguee, resolvingAgainstBaseURL: false)!
    searchURL.path = "/\(languagePair.lingueePath)/search"
    searchURL.queryItems = [
      self.sourceQueryItem,
      URLQueryItem(name: mode.rawValue, value: query),
    ]
    // TODO: throw an error if the URL creation fails.
    return searchURL.url!
  }
}

public class Linguee {
  public enum Error: Swift.Error {
    case badEncoding
    case generic(Swift.Error)
  }

  private let languagePair: LanguagePair
  private let loader: URLLoader
  private var cancellables = Set<AnyCancellable>()

  public init(languagePair: LanguagePair, loader: URLLoader = URLSession.shared) {
    self.languagePair = languagePair
    self.loader = loader
  }

  /// Returns a Linguee URL pointing at the `query` results.
  public static func searchURL(query: String, languagePair: LanguagePair)
    -> URL
  {
    return .linqueeSearch(query, mode: .regular, languagePair: languagePair)
  }

  public func search(for query: String) -> Future<[Autocompletion], Error> {
    return Future { (completion) in
      self.loader.requestData(
        for: .linqueeSearch(query, mode: .lightweight, languagePair: self.languagePair)
      )
      .tryMap { (data, _) -> String in
        // Linguee returns content in iso-8859-15 encoding.
        guard let html = String(data: data, encoding: .isoLatin1) else {
          throw Error.badEncoding
        }
        return html
      }
      .tryMap { html in
        let document = try SwiftSoup.parse(html)
        return try self.selectTranslations(in: document)
      }
      .sink(
        receiveCompletion: { result in
          switch result {
          case .failure(let error):
            completion(.failure(.generic(error)))
          default:
            return
          }
        },
        receiveValue: { results in
          completion(.success(results))
        }
      )
      .store(in: &self.cancellables)
    }
  }

  func selectTranslations(in document: Document) throws -> [Autocompletion] {
    return
      try document
      .select(".autocompletion_item")
      .compactMap(Autocompletion.from(autocompletionItem:))
  }
}
