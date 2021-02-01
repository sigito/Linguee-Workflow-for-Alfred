import Alfred
import Foundation
import Updater

extension Release {
  func alfredItem(workflowName: String) -> Item {
    return Item(
      title: "An update for \(workflowName) is available.",
      subtitle: "Update to version \(version).",
      arg: self.workflowURL.absoluteString,
      icon: .arrowDown,
      mods: [
        .cmd: .init(
          subtitle: "Open the \(self.version) release page", valid: true,
          arg: self.releaseURL.absoluteString)
      ],
      // TODO: maybe copy all the information available.
      text: [.copy: self.releaseURL.absoluteString])
  }
}
