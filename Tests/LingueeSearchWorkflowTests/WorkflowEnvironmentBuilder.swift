import Alfred
import Linguee
import LingueeTestData

@testable import LingueeSearchWorkflow

struct WorkflowEnvironmentBuilder {
  var languagePair: LanguagePair = .englishGerman
  var copyBehavior: CopyBehavior = .allWithPromotion

  var environment: WorkflowEnvironment {
    WorkflowEnvironment(environment: [
      "source_language": languagePair.source,
      "destination_language": languagePair.destination,
      "copy_behavior": copyBehavior.option.rawValue,
      "disable_copy_text_promotion": String(!copyBehavior.includePromotion),
    ])
  }
}
