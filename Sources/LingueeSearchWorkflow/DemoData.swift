import Alfred
import Foundation
import Linguee
import Updater

extension WorkflowEnvironment {
  var demoMode: Bool {
    return bool(forKey: "demo_mode")
  }
}

extension MainItem {
  fileprivate static let bereich = MainItem(
    phrase: "Bereich", wordTypes: ["m"],
    link: URL(string: "https://www.linguee.com/german-english/translation/Bereich.html")!)
}

extension Array where Element == TranslationItem {
  fileprivate static let bereich = [
    TranslationItem(translation: "area", wordTypes: ["n"]),
    TranslationItem(translation: "field", wordTypes: ["n"]),
    TranslationItem(translation: "group", wordTypes: ["n"]),
    TranslationItem(translation: "sector", wordTypes: ["n"]),
  ]
}

extension Autocompletion {
  fileprivate static let bereich = Autocompletion(
    mainItem: .bereich, translations: .bereich)
}

extension Release {
  fileprivate static let demoRelease = Release(
    version: "1.0.0",
    workflowURL: URL(
      string:
        "https://github.com/sigito/Linguee-Workflow-for-Alfred/releases/download/1.0.0/Linguee.Search.alfredworkflow"
    )!,
    releaseURL: URL(
      string: "https://github.com/sigito/Linguee-Workflow-for-Alfred/releases/tag/1.0.0")!,
    releaseDate: Date())
}

fileprivate enum DemoError: Error {
  case failedToFetchTranslations
}

extension Workflow {
  static var demo: Workflow {
    var workflow = Workflow()
    let query = TranslationQuery(text: "Bereich", languagePair: .englishGerman)
    let defaultFallback = DefaultFallback(query: query)
    workflow.add(Autocompletion.bereich.alfredItem(defaultFallback: defaultFallback, promote: true))
    workflow.add(Release.demoRelease.alfredItem(workflowName: "Linguee Search"))
    workflow.add(DemoError.failedToFetchTranslations.alfredItem)
    workflow.add(.fromDefaultFallback(defaultFallback))
    return workflow
  }
}
