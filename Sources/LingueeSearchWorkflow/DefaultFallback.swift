import Linguee

struct DefaultFallback {
  let text: String
  let arg: String

  init(query: TranslationQuery) {
    // Trim the query to be used in a direct search link.
    let trimmedQuery = query.text.trimmingCharacters(in: .whitespaces)
    self.text = "Search Linguee for '\(trimmedQuery)'"
    self.arg = query.url(withMode: .regular).absoluteString
  }
}
