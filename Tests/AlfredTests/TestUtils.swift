import Foundation
import Alfred

extension Modifier {
  static var testModifier: Modifier { .init(subtitle: "Open example", valid: true, arg: "https://example.com/") }
}
