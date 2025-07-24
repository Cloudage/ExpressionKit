import XCTest
@testable import ExpressionKit
import Foundation

final class ExpressionKitTests: XCTestCase {
    
    // MARK: - Basic Arithmetic Tests
    
    func testBasicArithmetic() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("2 + 3"), .number(5.0))
        XCTAssertEqual(try ExpressionKit.evaluate("10 - 3"), .number(7.0))
        XCTAssertEqual(try ExpressionKit.evaluate("4 * 5"), .number(20.0))
        XCTAssertEqual(try ExpressionKit.evaluate("15 / 3"), .number(5.0))
        XCTAssertEqual(try ExpressionKit.evaluate("2 + 3 * 4"), .number(14.0))
    }
    
    func testArithmeticPrecedence() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("2 + 3 * 4"), .number(14.0)) // 2 + (3 * 4)
        XCTAssertEqual(try ExpressionKit.evaluate("2 * 3 + 4"), .number(10.0)) // (2 * 3) + 4
        XCTAssertEqual(try ExpressionKit.evaluate("10 - 2 * 3"), .number(4.0)) // 10 - (2 * 3)
        XCTAssertEqual(try ExpressionKit.evaluate("12 / 3 + 2"), .number(6.0)) // (12 / 3) + 2
    }
    
    func testParenthesesGrouping() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("(2 + 3) * 4"), .number(20.0))
        XCTAssertEqual(try ExpressionKit.evaluate("2 * (3 + 4)"), .number(14.0))
        XCTAssertEqual(try ExpressionKit.evaluate("(10 - 2) / (3 + 1)"), .number(2.0))
        XCTAssertEqual(try ExpressionKit.evaluate("((2 + 3) * 4) - 1"), .number(19.0))
    }
    
    func testComplexArithmetic() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("(2 + 3) * 4 - 1"), .number(19.0))
        XCTAssertEqual(try ExpressionKit.evaluate("10 / (2 + 3) * 4"), .number(8.0))
        XCTAssertEqual(try ExpressionKit.evaluate("1 + 2 * 3 + 4"), .number(11.0))
        XCTAssertEqual(try ExpressionKit.evaluate("(1 + 2) * (3 + 4)"), .number(21.0))
    }
    
    // MARK: - Boolean Logic Tests
    
    func testBasicBooleanLogic() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("true"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("false"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("true && true"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("true && false"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("false && false"), .boolean(false))
    }
    
    func testLogicalOperators() throws {
        // AND operations
        XCTAssertEqual(try ExpressionKit.evaluate("true && true"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("true and true"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("true && false"), .boolean(false))
        
        // OR operations
        XCTAssertEqual(try ExpressionKit.evaluate("true || false"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("true or false"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("false || false"), .boolean(false))
        
        // NOT operations
        XCTAssertEqual(try ExpressionKit.evaluate("!true"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("not true"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("!false"), .boolean(true))
        
        // XOR operations
        XCTAssertEqual(try ExpressionKit.evaluate("true xor false"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("true xor true"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("false xor false"), .boolean(false))
    }
    
    func testBooleanPrecedence() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("true || false && false"), .boolean(true)) // true || (false && false)
        XCTAssertEqual(try ExpressionKit.evaluate("!false && true"), .boolean(true)) // (!false) && true
        XCTAssertEqual(try ExpressionKit.evaluate("true && false || true"), .boolean(true)) // (true && false) || true
    }
    
    func testBooleanParentheses() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("(true || false) && false"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("!(true && false)"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("(true xor false) && true"), .boolean(true))
    }
    
    // MARK: - Comparison Tests
    
    func testComparisonOperators() throws {
        // Equality
        XCTAssertEqual(try ExpressionKit.evaluate("5 == 5"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 == 3"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("5 != 3"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 != 5"), .boolean(false))
        
        // Less than / Greater than
        XCTAssertEqual(try ExpressionKit.evaluate("3 < 5"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 < 3"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("5 > 3"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("3 > 5"), .boolean(false))
        
        // Less than or equal / Greater than or equal
        XCTAssertEqual(try ExpressionKit.evaluate("3 <= 5"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 <= 5"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 <= 3"), .boolean(false))
        XCTAssertEqual(try ExpressionKit.evaluate("5 >= 3"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 >= 5"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("3 >= 5"), .boolean(false))
    }
    
    func testComparisonWithExpressions() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("(2 + 3) > 4"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("(2 * 3) == 6"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("(10 / 2) <= 5"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("(5 - 1) != 3"), .boolean(true))
    }
    
    func testMixedLogicalComparison() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("5 > 3 && 2 == 2"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("5 < 3 || 2 == 2"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("!(5 == 3) && true"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("(5 > 3) xor (2 == 3)"), .boolean(true))
    }
    
    // MARK: - Parse Once, Execute Many Tests
    
    func testParseOnceExecuteMany() throws {
        let expression = try ExpressionKit.parse("2 + 3 * 4")
        
        // Execute multiple times to ensure consistency
        for _ in 0..<1000 {
            let result = try expression.evaluate()
            XCTAssertEqual(result, .number(14.0))
        }
    }
    
    func testParseOnceComplexExpression() throws {
        let expression = try ExpressionKit.parse("(5 + 3) * 2 - 1")
        
        // Execute multiple times with same result
        for _ in 0..<100 {
            let result = try expression.evaluate()
            XCTAssertEqual(result, .number(15.0)) // (5 + 3) * 2 - 1 = 8 * 2 - 1 = 16 - 1 = 15
        }
    }
    
    func testParseOnceBooleanExpression() throws {
        let expression = try ExpressionKit.parse("true && (5 > 3)")
        
        for _ in 0..<100 {
            let result = try expression.evaluate()
            XCTAssertEqual(result, .boolean(true))
        }
    }
    
    func testMultipleExpressionsIndependence() throws {
        let expr1 = try ExpressionKit.parse("2 + 3")
        let expr2 = try ExpressionKit.parse("4 * 5")
        let expr3 = try ExpressionKit.parse("true && false")
        
        // Execute each multiple times to ensure independence
        for _ in 0..<50 {
            XCTAssertEqual(try expr1.evaluate(), .number(5.0))
            XCTAssertEqual(try expr2.evaluate(), .number(20.0))
            XCTAssertEqual(try expr3.evaluate(), .boolean(false))
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testParseErrors() {
        let invalidExpressions = [
            "1 + * 3",           // Invalid operator sequence
            "2 + ",              // Incomplete expression
            "* 3",               // Starting with operator
            "2 3",               // Missing operator
            ")",                 // Unmatched parenthesis
            "(",                 // Unmatched parenthesis
            "2 + (3 * 4",        // Missing closing parenthesis
            "2 + 3) * 4",        // Missing opening parenthesis
            "",                  // Empty expression
            "   ",               // Whitespace only
        ]
        
        for expr in invalidExpressions {
            XCTAssertThrowsError(try ExpressionKit.parse(expr)) { error in
                XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for: \(expr)")
            }
        }
    }
    
    func testEvaluationErrors() {
        let errorExpressions = [
            "1 / 0",             // Division by zero
            "0 / 0",             // Zero divided by zero
        ]
        
        for expr in errorExpressions {
            XCTAssertThrowsError(try ExpressionKit.evaluate(expr)) { error in
                XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for: \(expr)")
            }
        }
    }
    
    func testErrorMessages() {
        do {
            _ = try ExpressionKit.parse("1 + * 3")
            XCTFail("Should have thrown an error")
        } catch let error as ExpressionError {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error should have a meaningful message")
        } catch {
            XCTFail("Should throw ExpressionError, got: \(type(of: error))")
        }
    }
    
    // MARK: - Value Type Tests
    
    func testValueTypeChecking() throws {
        // Number values
        let numValue: Value = .number(42.0)
        XCTAssertTrue(numValue.isNumber)
        XCTAssertFalse(numValue.isBoolean)
        XCTAssertEqual(try numValue.asNumber(), 42.0)
        XCTAssertEqual(numValue.numberValue, 42.0)
        
        // Boolean values
        let boolValue: Value = .boolean(true)
        XCTAssertFalse(boolValue.isNumber)
        XCTAssertTrue(boolValue.isBoolean)
        XCTAssertEqual(try boolValue.asBoolean(), true)
        XCTAssertEqual(boolValue.booleanValue, true)
        
        // Type conversion errors
        XCTAssertThrowsError(try numValue.asBoolean())
        XCTAssertThrowsError(try boolValue.asNumber())
    }
    
    func testValueLiterals() {
        // Integer literal
        let intLiteral: Value = 42
        XCTAssertEqual(intLiteral, .number(42.0))
        
        // Float literal
        let floatLiteral: Value = 3.14
        XCTAssertEqual(floatLiteral, .number(3.14))
        
        // Boolean literals
        let trueLiteral: Value = true
        XCTAssertEqual(trueLiteral, .boolean(true))
        
        let falseLiteral: Value = false
        XCTAssertEqual(falseLiteral, .boolean(false))
    }
    
    func testValueEquality() {
        XCTAssertEqual(Value.number(5.0), Value.number(5.0))
        XCTAssertEqual(Value.boolean(true), Value.boolean(true))
        XCTAssertNotEqual(Value.number(5.0), Value.number(3.0))
        XCTAssertNotEqual(Value.boolean(true), Value.boolean(false))
        XCTAssertNotEqual(Value.number(5.0), Value.boolean(true))
    }
    
    func testValueDescription() {
        let numValue = Value.number(42.5)
        let boolValue = Value.boolean(true)
        
        XCTAssertFalse(String(describing: numValue).isEmpty)
        XCTAssertFalse(String(describing: boolValue).isEmpty)
    }
    
    // MARK: - Edge Cases and Special Values
    
    func testSpecialNumbers() throws {
        // Test zero
        XCTAssertEqual(try ExpressionKit.evaluate("0"), .number(0.0))
        XCTAssertEqual(try ExpressionKit.evaluate("0 + 5"), .number(5.0))
        XCTAssertEqual(try ExpressionKit.evaluate("5 * 0"), .number(0.0))
        
        // Test negative numbers
        XCTAssertEqual(try ExpressionKit.evaluate("-5"), .number(-5.0))
        XCTAssertEqual(try ExpressionKit.evaluate("-5 + 3"), .number(-2.0))
        XCTAssertEqual(try ExpressionKit.evaluate("(-5) * 2"), .number(-10.0))
        
        // Test decimal numbers
        XCTAssertEqual(try ExpressionKit.evaluate("3.14"), .number(3.14))
        // Use delta for floating point comparison due to precision
        let result = try ExpressionKit.evaluate("3.14 + 1")
        XCTAssertTrue(result.isNumber)
        XCTAssertEqual(result.data.number, 4.14, accuracy: 0.000001)
        XCTAssertEqual(try ExpressionKit.evaluate("2.5 * 2"), .number(5.0))
    }
    
    func testWhitespaceHandling() throws {
        XCTAssertEqual(try ExpressionKit.evaluate("  2  +  3  "), .number(5.0))
        XCTAssertEqual(try ExpressionKit.evaluate("\t2\t*\t3\t"), .number(6.0))
        XCTAssertEqual(try ExpressionKit.evaluate("( 2 + 3 ) * 4"), .number(20.0))
        XCTAssertEqual(try ExpressionKit.evaluate("true && false"), .boolean(false))
    }
    
    func testComplexNestedExpressions() throws {
        // Deeply nested arithmetic
        XCTAssertEqual(try ExpressionKit.evaluate("((2 + 3) * (4 + 1)) - ((3 * 2) + 1)"), .number(18.0))
        
        // Complex boolean logic
        XCTAssertEqual(try ExpressionKit.evaluate("(true && false) || (true && true)"), .boolean(true))
        XCTAssertEqual(try ExpressionKit.evaluate("!(false || (true && false))"), .boolean(true))
        
        // Mixed arithmetic and boolean
        XCTAssertEqual(try ExpressionKit.evaluate("(5 + 3) > 7 && (2 * 3) == 6"), .boolean(true))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceParseOnceVsParseMany() {
        let expression = "((2 + 3) * 4 - 1) / 2 + 5"
        let iterations = 10000
        
        // Test parse once, execute many
        let parseOnceTime = measureTime {
            do {
                let expr = try ExpressionKit.parse(expression)
                for _ in 0..<iterations {
                    _ = try expr.evaluate()
                }
            } catch {
                XCTFail("Parse once test failed: \(error)")
            }
        }
        
        // Test parse every time
        let parseManyTime = measureTime {
            for _ in 0..<iterations {
                do {
                    _ = try ExpressionKit.evaluate(expression)
                } catch {
                    XCTFail("Parse many test failed: \(error)")
                }
            }
        }
        
        // Parse once should be significantly faster
        XCTAssertLessThan(parseOnceTime, parseManyTime, "Parse once should be faster than parse many")
        
        // Log performance improvement
        let speedup = parseManyTime / parseOnceTime
        print("Performance improvement: \(String(format: "%.1fx", speedup)) faster")
    }
    
    func testPerformanceLargeNumberOfEvaluations() {
        measure {
            // Test with actual working expression
            do {
                let expression = try ExpressionKit.parse("(2 + 3) * 4 - 1")
                for _ in 0..<10000 {
                    _ = try expression.evaluate()
                }
            } catch {
                XCTFail("Performance test failed: \(error)")
            }
        }
    }
    
    // MARK: - Swift Wrapper Integration Tests
    
    func testSwiftAPICorrectness() throws {
        // Test that Swift API properly wraps C++ functionality
        
        // Direct evaluation
        let directResult = try ExpressionKit.evaluate("2 + 3 * 4")
        XCTAssertEqual(directResult, .number(14.0))
        
        // Parse and evaluate
        let expression = try ExpressionKit.parse("2 + 3 * 4")
        let parseResult = try expression.evaluate()
        XCTAssertEqual(parseResult, .number(14.0))
        
        // Results should be identical
        XCTAssertEqual(directResult, parseResult)
    }
    
    func testSwiftErrorHandling() {
        // Verify Swift error types are properly thrown
        XCTAssertThrowsError(try ExpressionKit.parse("1 + * 3")) { error in
            XCTAssertTrue(error is ExpressionError)
            if let expressionError = error as? ExpressionError {
                XCTAssertFalse(expressionError.localizedDescription.isEmpty)
            }
        }
    }
    
    func testMemoryManagement() throws {
        // Test that expressions can be created and destroyed without issues
        var expressions = [try ExpressionKit.parse("1 + 1")]  // Start with one to infer type
        expressions.removeAll()  // Clear the initial one
        
        for i in 0..<100 {
            let expr = try ExpressionKit.parse("\(i) + 1")
            expressions.append(expr)
        }
        
        // Evaluate all expressions
        for (i, expr) in expressions.enumerated() {
            let result = try expr.evaluate()
            XCTAssertEqual(result, .number(Double(i + 1)))
        }
        
        // Clear expressions to test cleanup
        expressions.removeAll()
    }
    
    // MARK: - Helper Methods
    
    private func measureTime<T>(_ operation: () throws -> T) rethrows -> TimeInterval {
        let startTime = Date()
        _ = try operation()
        return Date().timeIntervalSince(startTime)
    }
}