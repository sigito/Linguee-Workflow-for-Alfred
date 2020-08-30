import XCTest

@testable import Updater

class GitHubAPIImplTests: XCTestCase {
  private var loader: URLLoaderFake!
  private var api: GitHubAPIImpl!
  private let responseSubscriber = TestSubscriber<LatestRelease, GitHubAPIError>()

  override func setUpWithError() throws {
    loader = URLLoaderFake()
    api = GitHubAPIImpl(loader: loader)
  }

  /// Tests that a properly parsed response is retured by the API.
  func testSuccessfulResponse() throws {
    let expectedRelease = LatestRelease.sampleRelease
    loader.stubs.requestDataResult = { _ in
      let response = HTTPURLResponse(
        url: URL(string: "https://example.com/api")!, statusCode: 200, httpVersion: nil,
        headerFields: nil)!
      return .success((LatestRelease.sampleData, response))
    }
    let _ = api.getLatestRelease(user: "user", repository: "repo")
      .subscribe(responseSubscriber)

    responseSubscriber.waitForCompletion()?.assertSuccess()
    XCTAssertEqual(responseSubscriber.receivedValues.count, 1)
    let receivedRelease = try XCTUnwrap(responseSubscriber.receivedValues.first)
    XCTAssertNotNil(receivedRelease)
    XCTAssertEqual(receivedRelease.tagName, expectedRelease.tagName)
    XCTAssertEqual(receivedRelease.htmlURL, expectedRelease.htmlURL)
    XCTAssertEqual(receivedRelease.publishedAt, expectedRelease.publishedAt)
    XCTAssertEqual(receivedRelease.assets, expectedRelease.assets)
  }
}
