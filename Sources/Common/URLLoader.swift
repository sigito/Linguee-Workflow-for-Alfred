import Combine
import Foundation

public protocol URLLoader {
  func requestData(for url: URL) async throws -> (data: Data, response: URLResponse)
}

extension URLSession: URLLoader {
  public func requestData(for url: URL) async throws -> (data: Data, response: URLResponse) {
    if #available(macOS 12.0, *) {
      return try await self.data(from: url)
    } else {
      var cancellable: AnyCancellable?
      return try await withCheckedThrowingContinuation { continuation in
        cancellable = self.dataTaskPublisher(for: url)
          .sink { completion in
            if case .failure(let error) = completion {
              continuation.resume(throwing: error)
            }
            cancellable?.cancel()
            cancellable = nil
          } receiveValue: { result in
            continuation.resume(returning: result)
          }
      }
    }
  }
}
