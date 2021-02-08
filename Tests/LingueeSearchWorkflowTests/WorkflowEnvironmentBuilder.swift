import Alfred
import Linguee
import LingueeTestData

struct WorkflowEnvironmentBuilder {
  var languagePair: LanguagePair = .englishGerman

  var environment: WorkflowEnvironment {
    WorkflowEnvironment(environment: [
      "source_language": languagePair.source,
      "destination_language": languagePair.destination,
    ])
  }
}
