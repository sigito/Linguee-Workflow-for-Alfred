import Common
import Foundation
import SwiftSoup

public class Linguee {
  public enum Error: Swift.Error {
    case badEncoding
    case generic(Swift.Error)
  }

  private let loader: URLLoader

  public init(loader: URLLoader = URLSession.shared) {
    self.loader = loader
  }

  public func search(for query: TranslationQuery) async throws -> [Autocompletion] {
    let (data, response) = try await self.loader.requestData(for: query.url(withMode: .lightweight))
    let encoding = response.textEncoding ?? .utf8
    guard let html = String(data: data, encoding: encoding) else {
      throw Error.badEncoding
    }
    let document = try SwiftSoup.parse(html)
    return try self.selectTranslations(in: document)
  }

  // MARK: - Private

  private func selectTranslations(in document: Document) throws -> [Autocompletion] {
    return
      try document
      .select(".autocompletion_item")
      .compactMap(Autocompletion.from(autocompletionItem:))
  }

}
