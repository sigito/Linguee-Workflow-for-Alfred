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

var workflow = Workflow()
let fallback = DefaultFallback(query: query)

let linguee = Linguee()
let lingueeSearchRequset = linguee.search(for: query)
  .sink(
    receiveCompletion: { result in
      if case .failure(let error) = result {
        workflow.add(.init(valid: false, title: "Failed to get translations", subtitle: "\(error)"))
      }
      try! workflow.emit()
      exit(EXIT_SUCCESS)
    },
    receiveValue: { results in
      results
        .map { $0.alfredItem(defaultFallback: fallback) }
        .forEach { workflow.add($0) }
      // Add a direct search link to the end of the list.
      workflow.add(.fromDefaultFallback(fallback))
    })

RunLoop.main.run()
