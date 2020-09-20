import Combine
import Foundation

public protocol URLLoader {
  func requestData(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLLoader {
  public func requestData(for url: URL) -> AnyPublisher<
    (data: Data, response: URLResponse), URLError
  > {
    return self.dataTaskPublisher(for: url).eraseToAnyPublisher()
  }
}
