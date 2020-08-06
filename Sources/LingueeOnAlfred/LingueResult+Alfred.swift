import Alfred
import Linguee

extension LingueeResult {
  var alfredItem: Alfred.Item {
    return Alfred.Item(title: self.phrase,
                      subtitle: self.translations.joined(separator: ","),
                      arg: self.link.absoluteString)
  }
}
