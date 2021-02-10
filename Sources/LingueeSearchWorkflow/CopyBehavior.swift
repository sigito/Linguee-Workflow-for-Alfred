import Alfred
import Foundation

struct CopyBehavior {
  /// Select behavior option.
  var option: Option
  /// Whether the copy text should include promotion to the Linguee Workflow.
  /// Only affects the `.all` option.
  var includePromotion: Bool
}

extension CopyBehavior {
  enum Option: String {
    /// Fully formatted result, including the search query, translations and the results URL.
    case all = "all"

    /// The Lingue.com URL with the results.
    case url = "url"

    /// The first translation only.
    /// In case there no translations available, the initial query would be copied instead.
    case firstTranlationOnly = "first-translation-only"
  }
}

extension WorkflowEnvironment {
  /// The copy behavior set in the environment.
  var copyBehavior: CopyBehavior {
    let option = environment["copy_behavior"].flatMap(CopyBehavior.Option.init(rawValue:)) ?? .all
    return CopyBehavior(option: option, includePromotion: !disableCopyTextPromotion)
  }

  // MARK: - Private

  private var disableCopyTextPromotion: Bool {
    return bool(forKey: "disable_copy_text_promotion")
  }
}
