import XCTest
@testable import ExpressionKitTests

fileprivate extension ExpressionKitTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ExpressionKitTests = [
        ("testBasicArithmetic", testBasicArithmetic),
        ("testBooleanExpression", testBooleanExpression),
        ("testBooleanLogic", testBooleanLogic),
        ("testComparison", testComparison),
        ("testComplexArithmetic", testComplexArithmetic),
        ("testErrorHandling", testErrorHandling),
        ("testParseOnceComplex", testParseOnceComplex),
        ("testParseOnceExecuteMany", testParseOnceExecuteMany),
        ("testValueLiterals", testValueLiterals),
        ("testValueTypes", testValueTypes)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __ExpressionKitTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ExpressionKitTests.__allTests__ExpressionKitTests)
    ]
}