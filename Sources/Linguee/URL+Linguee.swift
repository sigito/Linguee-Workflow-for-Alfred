import Foundation

extension URL {
  static let linguee = URL(string: "https://www.linguee.com")!

  static func linguee(_ href: String) -> URL? {
    return URL(string: href, relativeTo: .linguee)
  }
}
