import Combine
import Foundation
import XCTest

class TestSubscriber<Input, Failure: Error>: Subscriber {
  var receivedValues: [Input] = []
  private let completionSemaphore = DispatchSemaphore(value: 1)
  private var completion: Subscribers.Completion<Failure>? = nil

  init() {
  }

  func waitForCompletion(_ timeout: DispatchTimeInterval = .milliseconds(100)) -> Subscribers
    .Completion<Failure>?
  {
    let waitResult = completionSemaphore.wait(timeout: .now() + timeout)
    XCTAssertEqual(waitResult, .success)
    return completion
  }

  // MARK: - Subscriber

  func receive(subscription: Subscription) {
    subscription.request(.unlimited)
  }

  func receive(_ input: Input) -> Subscribers.Demand {
    self.receivedValues.append(input)
    return .unlimited
  }

  func receive(completion: Subscribers.Completion<Failure>) {
    self.completion = completion
    completionSemaphore.signal()
  }
}

extension Subscribers.Completion {
  func assertSuccess() {
    if case .failure(let error) = self {
      XCTFail("Condition success not met. Failure with error: \(error)")
    }
  }

  typealias ErrorAssertionBlock = (Failure) throws -> Void
  func assertError(_ errorAssertion: ErrorAssertionBlock? = nil) rethrows {
    guard case .failure(let error) = self else {
      XCTFail("Succeeded when expecting a failure.")
      return
    }
    try errorAssertion?(error)
  }

  func assertError(_ expectedError: Failure) where Failure: Equatable {
    self.assertError { (error) in
      XCTAssertEqual(error, expectedError)
    }
  }
}
