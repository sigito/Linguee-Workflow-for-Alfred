import Foundation

extension URL {
  static let linguee = URL(string: "https://www.linguee.com/english-german/search")!
}

class Linguee {

  func search(_ query: String, completion: (Result) -> Void) {
    //    //https://www.linguee.com/english-german/search?source=auto&query=machen
    //    var searchURL = URL.linguee
    //    searchURL.query = "source=auto&query=machen"
  }

}

