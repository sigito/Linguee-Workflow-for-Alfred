import Combine
import Common
import Foundation

func notFaked1Fatal<T, R>(file: StaticString = #file, line: UInt = #line) -> (T) -> R {
  return { _ in fatalError("\(file):\(line) - Not faked!") }
}

public class URLLoaderFake: URLLoader {
  public class Stubs {
    public var requestDataResult: (URL) -> Result<(data: Data, response: URLResponse), URLError> =
      notFaked1Fatal()
  }
  public let stubs = Stubs()

  public init() {}

  public func requestData(for url: URL) -> AnyPublisher<
    (data: Data, response: URLResponse), URLError
  > {
    Future { (completion) in
      completion(self.stubs.requestDataResult(url))
    }.eraseToAnyPublisher()
  }
}
