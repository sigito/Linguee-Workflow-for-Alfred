import Alfred
import Foundation
import Linguee

// TODO: use ArgumentParser intead?
guard CommandLine.arguments.count > 1 else {
  fatalError("No query parameter provided.")
}
let query = CommandLine.arguments[1]
  // Macos stores the strings in a decomposed UTF8 encoding (aka. UTF8-MAC). Convert to a conanical UTF8 string.
  // https://www.unicode.org/reports/tr15/
  // https://developer.apple.com/library/archive/qa/qa1235/_index.html
  // https://stackoverflow.com/questions/23219482#23226449
  .precomposedStringWithCanonicalMapping


let linguee = Linguee()
linguee.search(for: query) { result in
  var workflow = Workflow()

  switch result {
  case .failure(let error):
    workflow.add(.init(valid: false, title: "Failed to get translations", subtitle: "\(error)"))
  case .success(let results):
    results
      .map { $0.alfredItem }
      .forEach { workflow.add($0) }
  }
  // Add a direct search link to the end of the list.
  let searchURL = Linguee.searchURL(query: query)
  workflow.add(.init(title: "Search Linguee for '\(query)'", arg: searchURL.absoluteString))
  try! workflow.emit()
  exit(EXIT_SUCCESS)
}

RunLoop.main.run()
