@testable import LingueeSearchWorkflow

extension CopyBehavior {
  static let all = CopyBehavior(option: .all, includePromotion: false)
  static let allWithPromotion = CopyBehavior(option: .all, includePromotion: true)
  static let firstTranslationOnly = CopyBehavior(
    option: .firstTranslationOnly, includePromotion: false)
  static let url = CopyBehavior(option: .url, includePromotion: false)
}
