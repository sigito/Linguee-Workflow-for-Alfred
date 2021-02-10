@testable import LingueeSearchWorkflow

extension CopyBehavior {
  static let all = CopyBehavior(option: .all, includePromotion: false)
  static let allWithPromotion = CopyBehavior(option: .all, includePromotion: true)
  static let firstTranlationOnly = CopyBehavior(
    option: .firstTranlationOnly, includePromotion: false)
  static let url = CopyBehavior(option: .url, includePromotion: false)
}
