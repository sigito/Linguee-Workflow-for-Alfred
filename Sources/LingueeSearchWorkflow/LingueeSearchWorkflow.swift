import Alfred
import Foundation
import Linguee
import Logging
import Updater

/// Usual amount of seconds in a minute.
fileprivate let kMinuteSeconds: TimeInterval = 60
/// Usual amount of secands in 5 minutes.
fileprivate let kFiveMituneSeconds = 5 * kMinuteSeconds
/// The new release caching period.
fileprivate let kReleaseCacheExpirationInterval = kMinuteSeconds * 60 * 24 * 3  // 3 days

public class LingueeSearchWorkflow {
  private static let logger = Logger(
    label: "\(LingueeSearchWorkflow.self)", factory: StreamLogHandler.standardError(label:))

  /// Provided enviroment.
  public let environment: WorkflowEnvironment
  /// The query to be searched for.
  public let query: TranslationQuery

  private let updateMonitor: UpdateMonitor?
  private let linguee: Linguee

  init(query: String, environment: WorkflowEnvironment = .init()) {
    self.query = TranslationQuery(text: query, environment: environment)
    self.environment = environment
    self.linguee = Linguee()
    self.updateMonitor = LingueeSearchWorkflow.makeUpdateMonitor(environment: environment)
  }

  private static func makeUpdateMonitor(
    environment: WorkflowEnvironment,
    enabled: Bool = false
  ) -> UpdateMonitor? {
    guard environment.checkForUpdates else {
      logger.debug("Update monitoring is disabled.")
      return nil
    }
    guard let worflowCacheDir = environment.workflowCache else {
      logger.error("No worflow cache dir was provided through environment.")
      return nil
    }
    do {
      let localStore = try LocalFileStore(rootDir: worflowCacheDir)
      let version = environment.workflowVersion.flatMap(Version.init) ?? .unknown
      return UpdateMonitor(
        currentVersion: version,
        requestInterval: kFiveMituneSeconds,
        cacheExpirationInterval: kReleaseCacheExpirationInterval,
        localStore: localStore,
        gitHubAPI: GitHubAPIImpl())
    } catch {
      logger.error("Failed to create update monitory: \(error)")
      return nil
    }
  }

  public func run() async throws -> Workflow {
    guard !self.environment.demoMode else {
      return .demo(with: self.environment)
    }

    async let release = self.fetchUpdate()

    var workflow = Workflow()
    let builder = AlfredItemBuilder(query: self.query, environment: self.environment)
    do {
      try await self.linguee.search(for: self.query)
        .map(builder.item(for:))
        .forEach { workflow.add($0) }
    } catch {
      workflow.add(builder.item(for: error))
    }
    if let release = try? await release {
      workflow.addAtLastVisiblePosition(builder.item(for: release))
    }
    // Add a direct search link to the end of the list.
    workflow.add(builder.openSearchOnLingueeItem())
    return workflow
  }

  public static func main() async throws {
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

    let lingueSearchWorkflow = LingueeSearchWorkflow(query: query)
    let workflow = try await lingueSearchWorkflow.run()
    try workflow.emit()
  }

  // MARK: - Private

  private func fetchUpdate() async throws -> Release? {
    guard let updateMonitor = updateMonitor else {
      return nil
    }
    return try await updateMonitor.availableUpdate()
  }
}
