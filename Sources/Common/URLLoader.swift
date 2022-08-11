import Combine
import Foundation

public protocol URLLoader {
  func requestData(for url: URL) async throws -> (data: Data, response: URLResponse)
}

extension URLSession: URLLoader {
  #if swift(<5.7)
    public func requestData(for url: URL) async throws -> (data: Data, response: URLResponse) {
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
  #else
    public func requestData(for url: URL) async throws -> (data: Data, response: URLResponse) {
      return try await self.data(from: url)
    }
  #endif
}
