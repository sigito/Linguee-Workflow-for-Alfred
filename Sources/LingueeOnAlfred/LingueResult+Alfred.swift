extension LingueeResult {
  var alfredItem: AlfredItem {
    return AlfredItem(title: self.phrase,
                      subtitle: self.translations.joined(separator: ","),
                      arg: self.link.absoluteString)
  }
}
