import Foundation

extension Date {
  static func daysAgo(_ days: Int) -> Self {
    return Calendar.current
      .date(byAdding: .day, value: -days, to: Date())!
  }

  static func minutesAgo(_ minutes: Int) -> Self {
    return Calendar.current
      .date(byAdding: .minute, value: -minutes, to: Date())!
  }
}
