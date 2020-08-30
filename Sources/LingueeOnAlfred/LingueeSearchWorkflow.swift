import Alfred
import Combine
import Foundation
import Linguee
import Logging
import Updater

/// Usual amount of seconds in a minute.
fileprivate let kMinuteSeconds: Int = 60
/// Usual amount of secands in 5 minutes.
fileprivate let kFiveMituneSeconds = 5 * kMinuteSeconds
/// Usual amount of seconds per week.
fileprivate let kWeekSeconds: Int = kMinuteSeconds * 60 * 24 * 7

class LingueeSearchWorkflow {
  private static let logger = Logger(
    label: "\(LingueeSearchWorkflow.self)", factory: StreamLogHandler.standardError(label:))
  private var cancellables: Set<AnyCancellable> = []
  private let query: String
  private let environment: WorkflowEnvironment
  private let updateMonitor: UpdateMonitor?
  private let linguee: Linguee

  init(query: String, environment: WorkflowEnvironment) {
    self.query = query
    self.environment = environment
    self.linguee = Linguee()
    self.updateMonitor = LingueeSearchWorkflow.makeUpdateMonitor(environment: environment)
  }

  private static func makeUpdateMonitor(
    environment: WorkflowEnvironment,
    enabled: Bool = false
  ) -> UpdateMonitor? {
    // TODO: enable the updater based on the external configuration.
    guard enabled else {
      logger.debug("Update monitoring is disabled.")
      return nil
    }
    guard let worflowCacheDir = environment.workflowCache else {
      logger.error("No worflow cache dir was provided through environment.")
      return nil
    }
    do {
      let localStore = try LocalFileStore(rootDir: worflowCacheDir)
      return UpdateMonitor(
        currentVersion: environment.workflowVersion,
        requestIntervalSec: kFiveMituneSeconds,
        cacheExpirationIntervalSec: kWeekSeconds,
        localStore: localStore,
        gitHubAPI: GitHubAPIImpl())
    } catch {
      logger.error("Failed to create update monitory: \(error)")
      return nil
    }
  }

  public func run() -> Future<Workflow, Error> {
    return Future { promise in
      var workflow = Workflow()
      self.linguee
        .search(for: self.query)
        // Erase error type.
        .mapError { $0 as Error }
        .combineLatest(
          self.fetchUpdate()
            // Ignore update lookup errors.
            .replaceError(with: nil)
            .setFailureType(to: Error.self)
        )
        .receive(on: DispatchQueue.main)
        .sink(
          receiveCompletion: { completion in
            if case .failure(let error) = completion {
              workflow.add(
                .init(valid: false, title: "Failed to get translations", subtitle: "\(error)"))
            }
            promise(.success(workflow))
          },
          receiveValue: { (autocompletions, release) in
            let fallback = DefaultFallback(query: self.query)
            autocompletions
              .map { $0.alfredItem(defaultFallback: fallback) }
              .forEach { workflow.add($0) }
            // Add a direct search link to the end of the list.
            workflow.add(.fromDefaultFallback(fallback))
          }
        )
        .store(in: &self.cancellables)
    }
  }

  public static func main() throws {
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

    let environment = WorkflowEnvironment()
    let lingueSearchWorkflow = LingueeSearchWorkflow(query: query, environment: environment)
    // Capture the cancellable in a variable, to prevent deallocation.
    var cancellable: AnyCancellable? = nil
    cancellable =
      lingueSearchWorkflow
      .run()
      .tryMap { workflow in
        try workflow.emit()
      }
      .ignoreOutput()
      .sink(
        receiveCompletion: { completion in
          // Perform a cancellable nil check to stop the linter from complaining about written but
          // never read variable.
          if cancellable != nil {
            cancellable = nil
          }
          switch completion {
          case .finished:
            exit(EXIT_SUCCESS)
          case .failure(let error):
            self.logger.error("Failed with \(error)")
            exit(EXIT_FAILURE)
          }
        }, receiveValue: { _ in })
    RunLoop.main.run()
  }

  // MARK: - Private

  private func fetchUpdate() -> Future<Release?, Error> {
    // TODO: implement me.
    return Future { completion in
      completion(.success(nil))
    }
  }
}
