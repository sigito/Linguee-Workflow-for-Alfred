import Foundation

// TODO: use ArgumentParser intead?
guard CommandLine.arguments.count > 1 else {
  fatalError("No query parameter provided.")
}
let query = CommandLine.arguments[1]


let linguee = Linguee()
linguee.search(for: query) { result in
  var workflow = Workflow()

  switch result {
  case .failure(let error):
    workflow.add(AlfredItem(title: "Failed to get translations", subtitle: error.localizedDescription, arg: "???"))
  case .success(let results):
    results
      .map { $0.alfredItem }
      .forEach { workflow.add($0) }
  }
  workflow.emit()
}

RunLoop.main.run()
