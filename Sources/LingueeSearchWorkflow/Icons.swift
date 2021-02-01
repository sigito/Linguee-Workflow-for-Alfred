import Alfred
import Foundation

extension Icon {
  // TODO: use path based on `workflowData` enviroment variable.
  static let logo: Self = .icon(location: "./logo.png")
  static let linguee: Self = .icon(location: "./linguee.png")
  static let arrowDown: Self = .icon(location: "./update.png")
  static let checkMark: Self = .icon(location: "./check.png")
  static let warning: Self = .icon(location: "./warning.png")
}
