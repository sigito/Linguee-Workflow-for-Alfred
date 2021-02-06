import Alfred
import Foundation

enum TestData {
  static var bereichItems: [Item] {
    let url = Bundle.module.url(forResource: "bereich-items", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode([Item].self, from: data)
  }
}
