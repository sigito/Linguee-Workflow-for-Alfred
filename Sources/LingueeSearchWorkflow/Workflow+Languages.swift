import Alfred
import Linguee

extension WorkflowEnvironment {
  var sourceLanguage: String {
    return environment["source_language", default: "english"]
  }

  var destinationLanguage: String {
    return environment["destination_language", default: "german"]
  }

  var translationDirection: TranslationDirection {
    guard let value = environment["translation_direction"],
      let direction = TranslationDirection(rawValue: value)
    else {
      return .auto
    }
    return direction
  }
}
