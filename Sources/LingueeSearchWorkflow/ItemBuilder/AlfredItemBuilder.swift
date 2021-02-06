import Alfred
import Foundation
import Linguee
import Updater

extension DefaultFallback {
  fileprivate var item: Item {
    return Item(title: text, arg: arg, icon: .linguee)
  }
}

class AlfredItemBuilder {
  let environment: WorkflowEnvironment

  private let fallback: DefaultFallback

  init(query: TranslationQuery, environment: WorkflowEnvironment) {
    self.environment = environment
    self.fallback = DefaultFallback(query: query)
  }

  func item(for autocompletion: Autocompletion) -> Item {
    return AutocompleteItemBuilder(
      autocompletion,
      fallback: fallback,
      copyTextPromotion: !environment.disableCopyTextPromotion
    ).item
  }

  func item(for release: Release) -> Item {
    let workflowName = environment.workflowName ?? "Linguee Search"
    return Item(
      title: "An update for \(workflowName) is available.",
      subtitle: "Update to version \(release.version).",
      arg: release.workflowURL.absoluteString,
      icon: .arrowDown,
      mods: [
        .cmd: .init(
          subtitle: "Open the \(release.version) release page", valid: true,
          arg: release.releaseURL.absoluteString)
      ],
      // TODO: maybe copy all the information available.
      text: [.copy: release.releaseURL.absoluteString])
  }

  func item(for error: Error) -> Item {
    return Item(
      valid: false,
      title: "Failed to get translations!",
      subtitle: "Details: \(error)",
      icon: .warning)
  }

  /// Returns an item to open the search query on Linguee.
  func openSearchOnLingueeItem() -> Item {
    return fallback.item
  }
}
