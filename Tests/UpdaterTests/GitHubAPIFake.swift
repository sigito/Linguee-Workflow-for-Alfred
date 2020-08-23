import Combine

@testable import Updater

func notFaked2<A, B, R>(file: StaticString = #file, line: UInt = #line) -> (A, B) -> R {
  return { _, _ in fatalError("\(file):\(line) - Not faked!") }
}

class GitHubAPIFake: GitHubAPI {
  class Stubs {
    var latestReleaseResult: (String, String) -> Result<LatestRelease?, GitHubAPIError> =
      notFaked2()
  }

  let stubs = Stubs()

  init() {}

  func getLatestRelease(user: String, repository: String) -> Future<LatestRelease?, GitHubAPIError>
  {
    Future { (completion) in
      completion(self.stubs.latestReleaseResult(user, repository))
    }
  }
}
