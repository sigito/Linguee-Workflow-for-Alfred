import Combine
import Foundation
import SwiftSoup

enum LingueQueryMode {
  /// No CSS payload.
  case lightweight
  /// Regular website.
  case regular

  private static let basePath = "english-german/search?source=auto"

  var queryParamaterName: String {
    switch self {
    case .lightweight:
      return "qe"
    case .regular:
      return "query"
    }
  }

  func path(for query: String) -> String? {
    guard let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return nil
    }
    return "\(LingueQueryMode.basePath)&\(self.queryParamaterName)=\(escapedQuery)"
  }
}

extension URL {

  static let linguee = URL(string: "https://www.linguee.com")!
  private static let lightweightQueryPath = "english-german/search?source=auto&qe="
  private static let regularQueryPath = "english-german/search?source=auto&query="

  static func linguee(_ href: String) -> URL? {
    return URL(string: href, relativeTo: .linguee)
  }

  /// Returns a URL to search for `query` on Linguee.
  /// `mode` specifies if the query URL should point at a website version with stripped CSS,
  /// or to a regular full-blown version.
  static func linqueeSearch(_ query: String, mode: LingueQueryMode) -> URL {
    // TODO: throw erros if creation fails.
    return .linguee(mode.path(for: query)!)!
  }
}

public class Linguee {
  public enum Error: Swift.Error {
    case badEncoding
    case generic(Swift.Error)
  }

  private var cancellables = Set<AnyCancellable>()

  public init() {}

  /// Returns a Linguee URL pointing at the `query` results.
  public static func searchURL(query: String) -> URL {
    return .linqueeSearch(query, mode: .regular)
  }

  public func search(for query: String, completion: @escaping (Result<[Autocompletion], Error>) -> Void) {
    URLSession.shared.dataTaskPublisher(for: .linqueeSearch(query, mode: .lightweight))
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
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { result in
        switch result {
        case .failure(let error):
          completion(.failure(.generic(error)))
        default:
          return
        }
      }, receiveValue: { results in
        completion(.success(results))
      })
      .store(in: &cancellables)
  }

  func selectTranslations(in document: Document) throws -> [Autocompletion] {
    return try document
      .select(".autocompletion_item")
      .compactMap(Autocompletion.from(autocompletionItem:))
  }
}
