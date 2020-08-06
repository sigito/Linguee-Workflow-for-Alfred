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

public struct LingueeResult {
  /// The transloted phrase.
  public var phrase: String
  /// The phrase translations.
  public var translations: [String]
  /// The link to this translation result.
  public var link: URL

  public init(phrase: String, translations: [String], link: URL) {
    self.phrase = phrase
    self.translations = translations
    self.link = link
  }
}

public class Linguee {
  public enum Error: Swift.Error {
    case badEncoding
    case generic(Swift.Error)
  }

  public init() {}

  private var cancellables = Set<AnyCancellable>()

  public func search(for query: String, completion: @escaping (Result<[LingueeResult], Error>) -> Void) {
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

  func selectTranslations(in document: Document) throws -> [LingueeResult] {
    return try document
      .select(".autocompletion_item")
      .compactMap(LingueeResult.parse(from:))
  }
}

extension LingueeResult {
  static func parse(from element: Element) throws -> Self? {
    guard try element.classNames().contains("autocompletion_item") else {
      preconditionFailure("The root element must have autocompletion_item class: \(element)")
    }
    guard let mainItem = try element.select(".main_item").first() else {
      fatalError("Cannot find 'main_item' in \(element)")
    }
    let hrefAttribute = try mainItem.attr("href")
    guard let url = URL.linguee(hrefAttribute) else {
      fatalError("'href' attribute content is not a URL: \(hrefAttribute)")
    }
    let translations = try element.select(".translation_row").map { try $0.text() }
    // TODO: add gender.
    return LingueeResult(phrase: try mainItem.text(), translations: translations, link: url)
  }
}
