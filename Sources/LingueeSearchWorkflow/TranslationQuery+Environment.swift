import Alfred
import Linguee

extension TranslationQuery {
  init(text: String, environment: WorkflowEnvironment) {
    let languagePair = LanguagePair(
      source: environment.sourceLanguage,
      destination: environment.destinationLanguage)
    self.init(
      text: text, languagePair: languagePair, translationDirection: environment.translationDirection
    )
  }
}
