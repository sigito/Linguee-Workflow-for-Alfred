import Combine
import Foundation

public struct Asset {
  var name: String
  var browserDownloadURL: URL
}

extension Asset: Decodable {
  private enum CodingKeys: String, CodingKey {
    case name
    case browserDownloadURL = "browser_download_url"
  }
}

public struct LatestRelease {
  let tagName: String
  /// The release page URL.
  let htmlURL: URL
  let publishedAt: Date
  let assets: [Asset]
}

extension LatestRelease: Decodable {
  private enum CodingKeys: String, CodingKey {
    case tagName = "tag_name"
    case htmlURL = "html_url"
    case publishedAt = "published_at"
    case assets
  }
}

extension URL {
  fileprivate static var gitHubAPI: URL {
    return URL(string: "https://api.github.com/")!
  }

  fileprivate static func latestRelease(user: String, repository: String) -> URL? {
    var components = URLComponents(url: .gitHubAPI, resolvingAgainstBaseURL: false)!
    // Try to encode the user and repository, or use raw if not possible.
    let sanitizedUser = user.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? user
    let sanitizedRepo =
      repository.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? repository
    components.path = "/repos/\(sanitizedUser)/\(sanitizedRepo)/releases/latest"
    return components.url
  }
}

public enum GitHubAPIError: Error {
  case cannotContructURL
  case unexpectedResponse
  case badResponseCode
  case generic(Error)
}

public protocol GitHubAPI {
  func getLatestRelease(user: String, repository: String) -> Future<LatestRelease?, GitHubAPIError>
}

public class GitHubAPIImpl: GitHubAPI {

  private var cancellables: Set<AnyCancellable> = []

  public init() {}

  public func getLatestRelease(user: String, repository: String) -> Future<
    LatestRelease?, GitHubAPIError
  > {
    return Future.init { completion in
      guard let latestReleaseURL = URL.latestRelease(user: user, repository: repository) else {
        completion(.failure(.cannotContructURL))
        return
      }
      URLSession.shared.dataTaskPublisher(for: latestReleaseURL)
        .tryMap { (data, response) in
          guard let httpURLResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.unexpectedResponse
          }
          if !(200...299).contains(httpURLResponse.statusCode) {
            throw GitHubAPIError.badResponseCode
          }
          let string = String(data: data, encoding: .utf8)!
          print(string)
          return data
        }
        .decode(type: LatestRelease.self, decoder: JSONDecoder())
        .sink(
          receiveCompletion: { (result) in
            if case .failure(let error) = result {
              completion(.failure(.generic(error)))
            }
          },
          receiveValue: { (release) in
            completion(.success(release))
          }
        )
        .store(in: &self.cancellables)
    }
  }
}
