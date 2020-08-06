import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(LingueeTypes_SwiftSoupTest.allTests),
  ]
}
#endif
