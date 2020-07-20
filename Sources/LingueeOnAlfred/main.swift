import Foundation

// TODO: use ArgumentParser intead?
guard let query = CommandLine.arguments.first else {
  fatalError("No query parameter provided.")
}

var workflow = Workflow()

let group = DispatchGroup()
let linguee = Linguee()
group.enter()
linguee.search(for: query) { result in
  group.leave()
}
group.wait()

workflow.emit()
