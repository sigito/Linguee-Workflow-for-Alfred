import CommonTesting
import XCTest

@testable import Updater

class GitHubAPIImplTests: XCTestCase {
  private var loader: URLLoaderFake!
  private var api: GitHubAPIImpl!

  override func setUpWithError() throws {
    loader = URLLoaderFake()
    api = GitHubAPIImpl(loader: loader)
  }

  /// Tests that a properly parsed response is retured by the API.
  func testSuccessfulResponse() async throws {
    let expectedRelease = LatestRelease.sampleRelease
    loader.stubs.requestDataResult = { _ in
      let response = HTTPURLResponse(
        url: URL(string: "https://example.com/api")!, statusCode: 200, httpVersion: nil,
        headerFields: nil)!
      return (LatestRelease.sampleData, response)
    }
    let release = try await api.getLatestRelease(user: "user", repository: "repo")
    XCTAssertEqual(release.tagName, expectedRelease.tagName)
    XCTAssertEqual(release.htmlURL, expectedRelease.htmlURL)
    XCTAssertEqual(release.publishedAt, expectedRelease.publishedAt)
    XCTAssertEqual(release.assets, expectedRelease.assets)
  }
}
