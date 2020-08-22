import Alfred
import Foundation

extension Modifier {
  static var testModifier: Modifier {
    .init(subtitle: "Open example", valid: true, arg: "https://example.com/")
  }
}
