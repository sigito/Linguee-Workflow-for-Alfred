import Common
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

extension Asset: Equatable {}

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
  case unexpectedResponseType
  case badResponseCode
  /// Latest release not found.
  case notFound
}

public protocol GitHubAPI {
  func getLatestRelease(user: String, repository: String) async throws -> LatestRelease
}

public class GitHubAPIImpl: GitHubAPI {

  private let loader: URLLoader

  public init(loader: URLLoader = URLSession.shared) {
    self.loader = loader
  }

  public func getLatestRelease(user: String, repository: String) async throws -> LatestRelease {
    guard let latestReleaseURL = URL.latestRelease(user: user, repository: repository) else {
      throw GitHubAPIError.cannotContructURL
    }
    let (data, response) = try await loader.requestData(for: latestReleaseURL)
    guard let httpURLResponse = response as? HTTPURLResponse else {
      throw GitHubAPIError.unexpectedResponseType
    }
    if !(200...299).contains(httpURLResponse.statusCode) {
      throw GitHubAPIError.badResponseCode
    }
    return try self.makeDecoder().decode(LatestRelease.self, from: data)
  }

  // MARK: - Private

  private func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }
}
