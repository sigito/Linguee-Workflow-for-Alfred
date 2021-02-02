import Combine
import Common
import Foundation
import SwiftSoup

public class Linguee {
  public enum Error: Swift.Error {
    case badEncoding
    case generic(Swift.Error)
  }

  private let loader: URLLoader
  private var cancellables = Set<AnyCancellable>()

  public init(loader: URLLoader = URLSession.shared) {
    self.loader = loader
  }

  public func search(for query: TranslationQuery) -> Future<[Autocompletion], Error> {
    return Future { (completion) in
      self.loader.requestData(for: query.url(withMode: .lightweight))
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

  // MARK: - Private

  private func selectTranslations(in document: Document) throws -> [Autocompletion] {
    return
      try document
      .select(".autocompletion_item")
      .compactMap(Autocompletion.from(autocompletionItem:))
  }
}
