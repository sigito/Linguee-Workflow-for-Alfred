import Combine
import Foundation
import SwiftSoup

extension URL {

  static let linguee = URL(string: "https://www.linguee.com")!

  static func linguee(_ href: String) -> URL? {
    return URL(string: href, relativeTo: .linguee)
  }

  static func linqueeSearch(_ query: String) -> URL {
    // https://www.linguee.com/english-german/search?qe=query&source=auto
    // TODO: throw erros if creation fails.
    let escaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    return URL(string: "english-german/search?source=auto&qe=\(escaped)", relativeTo: .linguee)!
  }
}

public class Linguee {
  public enum Error: Swift.Error {
    case badEncoding
    case generic(Swift.Error)
  }

  public init() {}

  private var cancellables = Set<AnyCancellable>()

  public func search(for query: String, completion: @escaping (Result<[Autocompletion], Error>) -> Void) {
    URLSession.shared.dataTaskPublisher(for: .linqueeSearch(query))
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
