import Alfred
import Linguee

extension WorkflowEnvironment {
  var sourceLanguage: String {
    return environment["source_language", default: "english"]
  }

  var destinationLanguage: String {
    return environment["destination_language", default: "german"]
  }
}
