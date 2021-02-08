import Foundation
import Linguee

extension Autocompletion {
  static var bereichData: Data {
    let url = Bundle.module.url(forResource: "bereich-translation-response", withExtension: "html")!
    return try! Data(contentsOf: url)
  }
}
