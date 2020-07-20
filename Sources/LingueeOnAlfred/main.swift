import Foundation

// TODO: use ArgumentParser intead?
guard CommandLine.arguments.count > 1 else {
  fatalError("No query parameter provided.")
}
let query = CommandLine.arguments[1] 

var workflow = Workflow()

let group = DispatchGroup()
let linguee = Linguee()
group.enter()
linguee.search(for: query) { result in
  group.leave()
}
group.wait()

workflow.emit()
