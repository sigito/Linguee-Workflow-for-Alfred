import Alfred
import Foundation
import Updater

extension Release {
  var alfredItem: Item {
    return Item(
      // TODO(#15): include the name of the workflow in the title/subtitle.
      title: "Update to \(self.version)",
      subtitle: "A newer version of the workflow is available.",
      arg: self.workflowURL.absoluteString,
      // TODO(#15): set a custom icon.
      icon: nil,
      mods: [
        .cmd: .init(
          subtitle: "Open the \(self.version) release page", valid: true,
          arg: self.releaseURL.absoluteString)
      ],
      // TODO: maybe copy all the information available.
      text: [.copy: self.releaseURL.absoluteString])
  }
}
