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
    return URL(string: "english-german/search?source=auto&qe=\(query)", relativeTo: .linguee)!
  }
}

struct LingueeResult {
  /// The transloted phrase.
  var phrase: String
  /// The phrase translations.
  var translations: [String]
  /// The link to this translation result.
  var link: URL
}

class Linguee {
  private var cancellables = Set<AnyCancellable>()

  func search(for query: String, completion: @escaping (Result<[LingueeResult], Error>) -> Void) {
    URLSession.shared.dataTaskPublisher(for: .linqueeSearch(query))
      .compactMap { (data, _) in
        String(data: data, encoding: .utf8)
      }
      .tryMap { html in
        let document = try SwiftSoup.parse(html)
        return try self.selectTranslations(in: document)
      }
      // TODO: prapagate the error.
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { result in
        switch result {
        case .failure(let error):
          completion(.failure(error))
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
    let translations = try element.select(".translation_item").map { $0.ownText() }
    // TODO: add gender.
    return LingueeResult(phrase: try mainItem.text(), translations: translations, link: url)
  }
}
