import Common
import Foundation

func notFaked1Fatal<T, R>(file: StaticString = #file, line: UInt = #line) -> (T) -> R {
  return { _ in fatalError("\(file):\(line) - Not faked!") }
}

public class URLLoaderFake: URLLoader {
  public class Stubs {
    public var requestDataResult: (URL) throws -> (data: Data, response: URLResponse) =
      notFaked1Fatal()
  }
  public let stubs = Stubs()

  public init() {}

  public func requestData(for url: URL) async throws -> (data: Data, response: URLResponse) {
    return try self.stubs.requestDataResult(url)
  }
}
