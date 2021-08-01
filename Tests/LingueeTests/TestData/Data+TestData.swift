import Foundation

extension Data {
  public static var bereichEnDeData: Data {
    let url = Bundle.module.url(
      forResource: "bereich-ende-translation-response", withExtension: "html")!
    return try! Data(contentsOf: url)
  }

  public static var helloEnJpData: Data {
    let url = Bundle.module.url(
      forResource: "hello-enjp-translation-response", withExtension: "html")!
    return try! Data(contentsOf: url)
  }
}
