import Combine
import Foundation

@testable import Updater

func notFaked1Fatal<T, R>(file: StaticString = #file, line: UInt = #line) -> (T) -> R {
  return { _ in fatalError("\(file):\(line) - Not faked!") }
}

class URLLoaderFake: URLLoader {
  class Stubs {
    var requestDataResult: (URL) -> Result<(data: Data, response: URLResponse), URLError> =
      notFaked1Fatal()
  }
  let stubs = Stubs()

  func requestData(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    Future { (completion) in
      completion(self.stubs.requestDataResult(url))
    }.eraseToAnyPublisher()
  }
}
