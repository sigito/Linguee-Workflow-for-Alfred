import Combine
import Foundation
import SwiftSoup

extension URL {
  static func linqueeSearch(_ query: String) -> URL {
    // https://www.linguee.com/english-german/search?qe=query&source=auto
    return URL(string: "https://www.linguee.com/english-german/search?source=auto&qe=\(query)")!
  }
}

struct LingueeResult {
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
        return self.selectTranslations(in: document)
      }
      // TODO: prapagate the error.
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { results in
        completion(.success(results))
      })
      .store(in: &cancellables)
  }

  func selectTranslations(in document: Document) -> [LingueeResult] {

    return []
  }
}
