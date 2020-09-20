import Combine
import Foundation
import XCTest

public class TestSubscriber<Input, Failure: Error>: Subscriber {
  public var receivedValues: [Input] = []
  private let completionSemaphore = DispatchSemaphore(value: 1)
  private var completion: Subscribers.Completion<Failure>? = nil

  public init() {
  }

  public func waitForCompletion(_ timeout: DispatchTimeInterval = .milliseconds(100)) -> Subscribers
    .Completion<Failure>?
  {
    let waitResult = completionSemaphore.wait(timeout: .now() + timeout)
    XCTAssertEqual(waitResult, .success)
    return completion
  }

  // MARK: - Subscriber

  public func receive(subscription: Subscription) {
    subscription.request(.unlimited)
  }

  public func receive(_ input: Input) -> Subscribers.Demand {
    self.receivedValues.append(input)
    return .unlimited
  }

  public func receive(completion: Subscribers.Completion<Failure>) {
    self.completion = completion
    completionSemaphore.signal()
  }
}

extension Subscribers.Completion {
  public func assertSuccess() {
    if case .failure(let error) = self {
      XCTFail("Condition success not met. Failure with error: \(error)")
    }
  }

  public typealias ErrorAssertionBlock = (Failure) throws -> Void
  public func assertError(_ errorAssertion: ErrorAssertionBlock? = nil) rethrows {
    guard case .failure(let error) = self else {
      XCTFail("Succeeded when expecting a failure.")
      return
    }
    try errorAssertion?(error)
  }

  public func assertError(_ expectedError: Failure) where Failure: Equatable {
    self.assertError { (error) in
      XCTAssertEqual(error, expectedError)
    }
  }
}
