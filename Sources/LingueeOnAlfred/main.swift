import Foundation

// TODO: use ArgumentParser intead?
guard CommandLine.arguments.count > 1 else {
  fatalError("No query parameter provided.")
}
let query = CommandLine.arguments[1].trimmingCharacters(in: .whitespacesAndNewlines)


let linguee = Linguee()
linguee.search(for: query) { result in
  var workflow = Alfred.Workflow()

  switch result {
  case .failure(let error):
    workflow.add(.init(title: "Failed to get translations", subtitle: "\(error)", arg: ""))
  case .success(let results):
    results
      .map { $0.alfredItem }
      .forEach { workflow.add($0) }
  }
  try! workflow.emit()
  exit(EXIT_SUCCESS)
}

RunLoop.main.run()
