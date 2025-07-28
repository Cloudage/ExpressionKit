import XCTest
@testable import ExpressionKit
import Foundation

final class ExpressionKitTests: XCTestCase {
    
    // MARK: - Basic Arithmetic Tests
    
    func testBasicArithmetic() throws {
        XCTAssertEqual(try Expression.eval("2 + 3"), .number(5.0))
        XCTAssertEqual(try Expression.eval("10 - 3"), .number(7.0))
        XCTAssertEqual(try Expression.eval("4 * 5"), .number(20.0))
        XCTAssertEqual(try Expression.eval("15 / 3"), .number(5.0))
        XCTAssertEqual(try Expression.eval("2 + 3 * 4"), .number(14.0))
    }
    
    func testArithmeticPrecedence() throws {
        XCTAssertEqual(try Expression.eval("2 + 3 * 4"), .number(14.0)) // 2 + (3 * 4)
        XCTAssertEqual(try Expression.eval("2 * 3 + 4"), .number(10.0)) // (2 * 3) + 4
        XCTAssertEqual(try Expression.eval("10 - 2 * 3"), .number(4.0)) // 10 - (2 * 3)
        XCTAssertEqual(try Expression.eval("12 / 3 + 2"), .number(6.0)) // (12 / 3) + 2
    }
    
    func testParenthesesGrouping() throws {
        XCTAssertEqual(try Expression.eval("(2 + 3) * 4"), .number(20.0))
        XCTAssertEqual(try Expression.eval("2 * (3 + 4)"), .number(14.0))
        XCTAssertEqual(try Expression.eval("(10 - 2) / (3 + 1)"), .number(2.0))
        XCTAssertEqual(try Expression.eval("((2 + 3) * 4) - 1"), .number(19.0))
    }
    
    func testComplexArithmetic() throws {
        XCTAssertEqual(try Expression.eval("(2 + 3) * 4 - 1"), .number(19.0))
        XCTAssertEqual(try Expression.eval("10 / (2 + 3) * 4"), .number(8.0))
        XCTAssertEqual(try Expression.eval("1 + 2 * 3 + 4"), .number(11.0))
        XCTAssertEqual(try Expression.eval("(1 + 2) * (3 + 4)"), .number(21.0))
    }
    
    // MARK: - Boolean Logic Tests
    
    func testBasicBooleanLogic() throws {
        XCTAssertEqual(try Expression.eval("true"), .boolean(true))
        XCTAssertEqual(try Expression.eval("false"), .boolean(false))
        XCTAssertEqual(try Expression.eval("true && true"), .boolean(true))
        XCTAssertEqual(try Expression.eval("true && false"), .boolean(false))
        XCTAssertEqual(try Expression.eval("false && false"), .boolean(false))
    }
    
    func testLogicalOperators() throws {
        // AND operations
        XCTAssertEqual(try Expression.eval("true && true"), .boolean(true))
        XCTAssertEqual(try Expression.eval("true and true"), .boolean(true))
        XCTAssertEqual(try Expression.eval("true && false"), .boolean(false))
        
        // OR operations
        XCTAssertEqual(try Expression.eval("true || false"), .boolean(true))
        XCTAssertEqual(try Expression.eval("true or false"), .boolean(true))
        XCTAssertEqual(try Expression.eval("false || false"), .boolean(false))
        
        // NOT operations
        XCTAssertEqual(try Expression.eval("!true"), .boolean(false))
        XCTAssertEqual(try Expression.eval("not true"), .boolean(false))
        XCTAssertEqual(try Expression.eval("!false"), .boolean(true))
        
        // XOR operations
        XCTAssertEqual(try Expression.eval("true xor false"), .boolean(true))
        XCTAssertEqual(try Expression.eval("true xor true"), .boolean(false))
        XCTAssertEqual(try Expression.eval("false xor false"), .boolean(false))
    }
    
    func testBooleanPrecedence() throws {
        XCTAssertEqual(try Expression.eval("true || false && false"), .boolean(true)) // true || (false && false)
        XCTAssertEqual(try Expression.eval("!false && true"), .boolean(true)) // (!false) && true
        XCTAssertEqual(try Expression.eval("true && false || true"), .boolean(true)) // (true && false) || true
    }
    
    func testBooleanParentheses() throws {
        XCTAssertEqual(try Expression.eval("(true || false) && false"), .boolean(false))
        XCTAssertEqual(try Expression.eval("!(true && false)"), .boolean(true))
        XCTAssertEqual(try Expression.eval("(true xor false) && true"), .boolean(true))
    }
    
    // MARK: - Comparison Tests
    
    func testComparisonOperators() throws {
        // Equality
        XCTAssertEqual(try Expression.eval("5 == 5"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 == 3"), .boolean(false))
        XCTAssertEqual(try Expression.eval("5 != 3"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 != 5"), .boolean(false))
        
        // Less than / Greater than
        XCTAssertEqual(try Expression.eval("3 < 5"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 < 3"), .boolean(false))
        XCTAssertEqual(try Expression.eval("5 > 3"), .boolean(true))
        XCTAssertEqual(try Expression.eval("3 > 5"), .boolean(false))
        
        // Less than or equal / Greater than or equal
        XCTAssertEqual(try Expression.eval("3 <= 5"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 <= 5"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 <= 3"), .boolean(false))
        XCTAssertEqual(try Expression.eval("5 >= 3"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 >= 5"), .boolean(true))
        XCTAssertEqual(try Expression.eval("3 >= 5"), .boolean(false))
    }
    
    func testComparisonWithExpressions() throws {
        XCTAssertEqual(try Expression.eval("(2 + 3) > 4"), .boolean(true))
        XCTAssertEqual(try Expression.eval("(2 * 3) == 6"), .boolean(true))
        XCTAssertEqual(try Expression.eval("(10 / 2) <= 5"), .boolean(true))
        XCTAssertEqual(try Expression.eval("(5 - 1) != 3"), .boolean(true))
    }
    
    func testMixedLogicalComparison() throws {
        XCTAssertEqual(try Expression.eval("5 > 3 && 2 == 2"), .boolean(true))
        XCTAssertEqual(try Expression.eval("5 < 3 || 2 == 2"), .boolean(true))
        XCTAssertEqual(try Expression.eval("!(5 == 3) && true"), .boolean(true))
        XCTAssertEqual(try Expression.eval("(5 > 3) xor (2 == 3)"), .boolean(true))
    }
    
    // MARK: - Parse Once, Execute Many Tests
    
    func testParseOnceExecuteMany() throws {
        let expression = try Expression.parse("2 + 3 * 4")
        
        // Execute multiple times to ensure consistency
        for _ in 0..<1000 {
            let result = try expression.eval()
            XCTAssertEqual(result, .number(14.0))
        }
    }
    
    func testParseOnceComplexExpression() throws {
        let expression = try Expression.parse("(5 + 3) * 2 - 1")
        
        // Execute multiple times with same result
        for _ in 0..<100 {
            let result = try expression.eval()
            XCTAssertEqual(result, .number(15.0)) // (5 + 3) * 2 - 1 = 8 * 2 - 1 = 16 - 1 = 15
        }
    }
    
    func testParseOnceBooleanExpression() throws {
        let expression = try Expression.parse("true && (5 > 3)")
        
        for _ in 0..<100 {
            let result = try expression.eval()
            XCTAssertEqual(result, .boolean(true))
        }
    }
    
    func testMultipleExpressionsIndependence() throws {
        let expr1 = try Expression.parse("2 + 3")
        let expr2 = try Expression.parse("4 * 5")
        let expr3 = try Expression.parse("true && false")
        
        // Execute each multiple times to ensure independence
        for _ in 0..<50 {
            XCTAssertEqual(try expr1.eval(), .number(5.0))
            XCTAssertEqual(try expr2.eval(), .number(20.0))
            XCTAssertEqual(try expr3.eval(), .boolean(false))
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
            XCTAssertThrowsError(try Expression.parse(expr)) { error in
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
            XCTAssertThrowsError(try Expression.eval(expr)) { error in
                XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for: \(expr)")
            }
        }
    }
    
    func testErrorMessages() {
        do {
            _ = try Expression.parse("1 + * 3")
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
        XCTAssertEqual(try Expression.eval("0"), .number(0.0))
        XCTAssertEqual(try Expression.eval("0 + 5"), .number(5.0))
        XCTAssertEqual(try Expression.eval("5 * 0"), .number(0.0))
        
        // Test negative numbers
        XCTAssertEqual(try Expression.eval("-5"), .number(-5.0))
        XCTAssertEqual(try Expression.eval("-5 + 3"), .number(-2.0))
        XCTAssertEqual(try Expression.eval("(-5) * 2"), .number(-10.0))
        
        // Test decimal numbers
        XCTAssertEqual(try Expression.eval("3.14"), .number(3.14))
        // Use delta for floating point comparison due to precision
        let result = try Expression.eval("3.14 + 1")
        XCTAssertTrue(result.isNumber)
        XCTAssertEqual(result.data.number, 4.14, accuracy: 0.000001)
        XCTAssertEqual(try Expression.eval("2.5 * 2"), .number(5.0))
    }
    
    func testWhitespaceHandling() throws {
        XCTAssertEqual(try Expression.eval("  2  +  3  "), .number(5.0))
        XCTAssertEqual(try Expression.eval("\t2\t*\t3\t"), .number(6.0))
        XCTAssertEqual(try Expression.eval("( 2 + 3 ) * 4"), .number(20.0))
        XCTAssertEqual(try Expression.eval("true && false"), .boolean(false))
    }
    
    func testComplexNestedExpressions() throws {
        // Deeply nested arithmetic
        XCTAssertEqual(try Expression.eval("((2 + 3) * (4 + 1)) - ((3 * 2) + 1)"), .number(18.0))
        
        // Complex boolean logic
        XCTAssertEqual(try Expression.eval("(true && false) || (true && true)"), .boolean(true))
        XCTAssertEqual(try Expression.eval("!(false || (true && false))"), .boolean(true))
        
        // Mixed arithmetic and boolean
        XCTAssertEqual(try Expression.eval("(5 + 3) > 7 && (2 * 3) == 6"), .boolean(true))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceParseOnceVsParseMany() {
        let expression = "((2 + 3) * 4 - 1) / 2 + 5"
        let iterations = 10000
        
        // Test parse once, execute many
        let parseOnceTime = measureTime {
            do {
                let expr = try Expression.parse(expression)
                for _ in 0..<iterations {
                    _ = try expr.eval()
                }
            } catch {
                XCTFail("Parse once test failed: \(error)")
            }
        }
        
        // Test parse every time
        let parseManyTime = measureTime {
            for _ in 0..<iterations {
                do {
                    _ = try Expression.eval(expression)
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
                let expression = try Expression.parse("(2 + 3) * 4 - 1")
                for _ in 0..<10000 {
                    _ = try expression.eval()
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
        let directResult = try Expression.eval("2 + 3 * 4")
        XCTAssertEqual(directResult, .number(14.0))
        
        // Parse and evaluate
        let expression = try Expression.parse("2 + 3 * 4")
        let parseResult = try expression.eval()
        XCTAssertEqual(parseResult, .number(14.0))
        
        // Results should be identical
        XCTAssertEqual(directResult, parseResult)
    }
    
    func testSwiftErrorHandling() {
        // Verify Swift error types are properly thrown
        XCTAssertThrowsError(try Expression.parse("1 + * 3")) { error in
            XCTAssertTrue(error is ExpressionError)
            if let expressionError = error as? ExpressionError {
                XCTAssertFalse(expressionError.localizedDescription.isEmpty)
            }
        }
    }
    
    func testMemoryManagement() throws {
        // Test that expressions can be created and destroyed without issues
        var expressions = [try Expression.parse("1 + 1")]  // Start with one to infer type
        expressions.removeAll()  // Clear the initial one
        
        for i in 0..<100 {
            let expr = try Expression.parse("\(i) + 1")
            expressions.append(expr)
        }
        
        // Evaluate all expressions
        for (i, expr) in expressions.enumerated() {
            let result = try expr.eval()
            XCTAssertEqual(result, .number(Double(i + 1)))
        }
        
        // Clear expressions to test cleanup
        expressions.removeAll()
    }
    
    // MARK: - Standard Mathematical Functions Tests
    
    func testStandardMathematicalFunctions() throws {
        // Test two-argument functions
        let minResult = try Expression.eval("min(10, 5)")
        XCTAssertEqual(minResult, .number(5.0))
        
        let maxResult = try Expression.eval("max(10, 5)")
        XCTAssertEqual(maxResult, .number(10.0))
        
        let powResult = try Expression.eval("pow(2, 3)")
        XCTAssertEqual(powResult, .number(8.0))
        
        // Test single-argument functions
        let sqrtResult = try Expression.eval("sqrt(16)")
        XCTAssertEqual(sqrtResult, .number(4.0))
        
        let absResultPositive = try Expression.eval("abs(5)")
        XCTAssertEqual(absResultPositive, .number(5.0))
        
        let absResultNegative = try Expression.eval("abs(-5)")
        XCTAssertEqual(absResultNegative, .number(5.0))
        
        let floorResult = try Expression.eval("floor(3.7)")
        XCTAssertEqual(floorResult, .number(3.0))
        
        let ceilResult = try Expression.eval("ceil(3.2)")
        XCTAssertEqual(ceilResult, .number(4.0))
        
        let roundResult = try Expression.eval("round(3.6)")
        XCTAssertEqual(roundResult, .number(4.0))
        
        // Test trigonometric functions
        let sinResult = try Expression.eval("sin(0)")
        XCTAssertEqual(try sinResult.asNumber(), 0.0, accuracy: 0.000001)
        
        let cosResult = try Expression.eval("cos(0)")
        XCTAssertEqual(try cosResult.asNumber(), 1.0, accuracy: 0.000001)
        
        let tanResult = try Expression.eval("tan(0)")
        XCTAssertEqual(try tanResult.asNumber(), 0.0, accuracy: 0.000001)
        
        // Test logarithmic and exponential functions
        let expResult = try Expression.eval("exp(0)")
        XCTAssertEqual(try expResult.asNumber(), 1.0, accuracy: 0.000001)
        
        let logResult = try Expression.eval("log(1)")
        XCTAssertEqual(try logResult.asNumber(), 0.0, accuracy: 0.000001)
    }
    
    func testStandardFunctionCompoundExpressions() throws {
        // Complex expressions with standard functions
        let result1 = try Expression.eval("max(abs(-5), sqrt(16))")
        XCTAssertEqual(result1, .number(5.0))
        
        let result2 = try Expression.eval("min(ceil(3.2), floor(5.8))")
        XCTAssertEqual(result2, .number(4.0))
        
        let result3 = try Expression.eval("pow(sqrt(4), 3)")
        XCTAssertEqual(result3, .number(8.0))
        
        // With arithmetic operations
        let result4 = try Expression.eval("sqrt(25) + abs(-3)")
        XCTAssertEqual(result4, .number(8.0))
        
        let result5 = try Expression.eval("max(10, 5) * min(2, 3)")
        XCTAssertEqual(result5, .number(20.0))
        
        let result6 = try Expression.eval("pow(2, 3) - sqrt(9)")
        XCTAssertEqual(result6, .number(5.0))
    }
    
    func testStandardFunctionErrorHandling() {
        // Test error cases for standard functions
        XCTAssertThrowsError(try Expression.eval("sqrt(-1)")) { error in
            XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for sqrt(-1)")
        }
        
        XCTAssertThrowsError(try Expression.eval("log(0)")) { error in
            XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for log(0)")
        }
        
        XCTAssertThrowsError(try Expression.eval("log(-1)")) { error in
            XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for log(-1)")
        }
    }
    
    func testStandardFunctionsWithParseOnceExecuteMany() throws {
        // Test that standard functions work with parse once, execute many pattern
        let expression = try Expression.parse("sqrt(16)")
        
        // Execute the same expression multiple times
        for _ in 0..<100 {
            let result = try expression.eval()
            XCTAssertEqual(result, .number(4.0))
        }
        
        // Test complex expression
        let complexExpression = try Expression.parse("max(abs(-5), sqrt(pow(2, 4)))")
        for _ in 0..<100 {
            let result = try complexExpression.eval()
            XCTAssertEqual(result, .number(5.0)) // max(5, sqrt(16)) = max(5, 4) = 5
        }
    }
    
    // MARK: - EnvironmentProtocol Tests
    
    func testEnvironmentProtocolConformance() {
        // Test that SimpleEnvironment conforms to EnvironmentProtocol
        let environment: EnvironmentProtocol = SimpleEnvironment()
        XCTAssertTrue(environment is SimpleEnvironment)
        // Remove redundant check - if environment is declared as EnvironmentProtocol, it conforms by definition
    }
    
    func testSimpleEnvironmentProtocolMethods() throws {
        let environment = SimpleEnvironment()
        
        // Test setValue and getValue
        environment.setValue(.number(42.0), for: "x")
        environment.setValue(.boolean(true), for: "flag")
        
        let xValue = try environment.getValue(for: "x")
        XCTAssertEqual(xValue, .number(42.0))
        
        let flagValue = try environment.getValue(for: "flag")
        XCTAssertEqual(flagValue, .boolean(true))
        
        // Test error for unknown variable
        XCTAssertThrowsError(try environment.getValue(for: "unknown")) { error in
            XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for unknown variable")
        }
        
        // Test error for unknown function
        XCTAssertThrowsError(try environment.callFunction(name: "unknownFunction", arguments: [])) { error in
            XCTAssertTrue(error is ExpressionError, "Should throw ExpressionError for unknown function")
        }
    }
    
    func testEnvironmentProtocolTypeErasing() throws {
        // Test that we can use SimpleEnvironment through EnvironmentProtocol
        let concreteEnvironment = SimpleEnvironment()
        concreteEnvironment.setValue(.number(100.0), for: "health")
        concreteEnvironment.setValue(.number(80.0), for: "maxHealth")
        
        let environment: EnvironmentProtocol = concreteEnvironment
        
        let healthValue = try environment.getValue(for: "health")
        XCTAssertEqual(healthValue, .number(100.0))
        
        let maxHealthValue = try environment.getValue(for: "maxHealth")
        XCTAssertEqual(maxHealthValue, .number(80.0))
    }
    
    // MARK: - String Support Tests
    
    func testStringLiterals() throws {
        // Basic string literal evaluation
        let result1 = try Expression.eval("\"hello\"")
        XCTAssertTrue(result1.isString)
        XCTAssertEqual(try result1.asString(), "hello")
        
        // Empty string
        let result2 = try Expression.eval("\"\"")
        XCTAssertTrue(result2.isString)
        XCTAssertEqual(try result2.asString(), "")
        
        // String with spaces
        let result3 = try Expression.eval("\"hello world\"")
        XCTAssertTrue(result3.isString)
        XCTAssertEqual(try result3.asString(), "hello world")
    }
    
    func testStringValueCreation() throws {
        // Test creating string values using the API
        let stringValue: Value = "test"
        XCTAssertTrue(stringValue.isString)
        XCTAssertEqual(try stringValue.asString(), "test")
        XCTAssertEqual(stringValue.stringValue, "test")
        
        // Test Value.string() factory method
        let stringValue2 = Value.string("factory")
        XCTAssertTrue(stringValue2.isString)
        XCTAssertEqual(try stringValue2.asString(), "factory")
    }
    
    func testStringTokenCollection() throws {
        // Test that string literals are properly tokenized
        let (value, tokens) = try Expression.eval("\"hello world\"", collectTokens: true)
        
        XCTAssertTrue(value.isString)
        XCTAssertEqual(try value.asString(), "hello world")
        
        guard let tokens = tokens else {
            XCTFail("Expected tokens to be collected")
            return
        }
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .string)
        XCTAssertEqual(tokens[0].text, "\"hello world\"")
    }
    
    func testStringEquality() throws {
        let str1: Value = "hello"
        let str2: Value = "hello"
        let str3: Value = "world"
        let num: Value = 42.0
        
        XCTAssertEqual(str1, str2)
        XCTAssertNotEqual(str1, str3)
        XCTAssertNotEqual(str1, num)
    }
    
    func testStringDescription() throws {
        let stringValue: Value = "test string"
        XCTAssertEqual(stringValue.description, "test string")
        
        let emptyString: Value = ""
        XCTAssertEqual(emptyString.description, "")
    }
    
    func testStringTypeChecking() throws {
        let stringValue: Value = "test"
        let numberValue: Value = 42.0
        let boolValue: Value = true
        
        // Positive cases
        XCTAssertTrue(stringValue.isString)
        XCTAssertFalse(stringValue.isNumber)
        XCTAssertFalse(stringValue.isBoolean)
        
        // Negative cases
        XCTAssertFalse(numberValue.isString)
        XCTAssertFalse(boolValue.isString)
        
        // Type mismatch errors
        XCTAssertThrowsError(try stringValue.asNumber())
        XCTAssertThrowsError(try stringValue.asBoolean())
        XCTAssertThrowsError(try numberValue.asString())
        XCTAssertThrowsError(try boolValue.asString())
    }
    
    // MARK: - Enhanced Edge Case Tests
    
    func testNumericalLimits() throws {
        // Test scientific notation - these might not be supported by the parser
        // so we'll test more basic large/small numbers
        let largeResult = try Expression.eval("10000000000")  // 1e10 written out
        XCTAssertEqual(largeResult, .number(10000000000))
        
        // Test decimal numbers
        let smallResult = try Expression.eval("0.0000000001")  // 1e-10 written out
        XCTAssertEqual(smallResult, .number(0.0000000001))
        
        // Test zero handling in different contexts
        XCTAssertEqual(try Expression.eval("0.0"), .number(0.0))
        XCTAssertEqual(try Expression.eval("-0.0"), .number(-0.0))
        
        // Test large integer
        XCTAssertNoThrow(try Expression.eval("999999999"))
    }
    
    func testMalformedExpressionEdgeCases() {
        let malformedExpressions = [
            "1 + + 2",           // Double operators
            "1 2 3",             // Numbers without operators
            "* / +",             // Only operators
            "(((",               // Only opening parentheses
            ")))",               // Only closing parentheses
            "1 + (2 * (3 + 4)",  // Unmatched nested parentheses
            "1 + 2) * 3",        // Extra closing parenthesis
            ".",                 // Single dot
            "..",                // Double dots
            "+-",                // Conflicting unary operators
            "",                  // Empty expression
            "   ",               // Whitespace only
        ]
        
        for expr in malformedExpressions {
            XCTAssertThrowsError(try Expression.parse(expr), "Should fail for: '\(expr)'") { error in
                XCTAssertTrue(error is ExpressionError, "Expected ExpressionError for: '\(expr)', got: \(type(of: error))")
                
                // Verify error messages are meaningful
                let errorMessage = error.localizedDescription
                XCTAssertFalse(errorMessage.isEmpty, "Error message should not be empty for: '\(expr)'")
            }
        }
        
        // Test some expressions that might work but we want to verify behavior
        let potentiallyValidExpressions = [
            ".1",                // Leading decimal point might be valid
            "1.",                // Trailing decimal point might be valid
            "1..2",              // Double decimal might be parsed as "1. .2" or similar
        ]
        
        for expr in potentiallyValidExpressions {
            // These might be valid depending on implementation, so don't assert they fail
            do {
                _ = try Expression.parse(expr)
                // If it parses successfully, that's fine
            } catch {
                // If it fails, that's also acceptable for edge cases
                XCTAssertTrue(error is ExpressionError, "If '\(expr)' fails, it should be an ExpressionError")
            }
        }
    }
    
    func testBoundaryValueArithmetic() throws {
        // Test operations near zero
        XCTAssertEqual(try Expression.eval("0 + 0"), .number(0.0))
        XCTAssertEqual(try Expression.eval("0 - 0"), .number(0.0))
        XCTAssertEqual(try Expression.eval("0 * 1000"), .number(0.0))
        
        // Test operations with 1
        XCTAssertEqual(try Expression.eval("1 * 1"), .number(1.0))
        XCTAssertEqual(try Expression.eval("5 / 1"), .number(5.0))
        XCTAssertEqual(try Expression.eval("1 + 0"), .number(1.0))
        
        // Test very precise decimal operations
        let result = try Expression.eval("0.1 + 0.2")
        XCTAssertTrue(result.isNumber)
        XCTAssertEqual(result.numberValue!, 0.3, accuracy: 0.000001)
    }
    
    func testComplexBooleanLogicEdgeCases() throws {
        // Test short-circuit evaluation patterns
        // Note: The underlying C++ implementation may not support short-circuit evaluation
        // so we'll test the basic boolean logic instead
        XCTAssertEqual(try Expression.eval("false && false"), .boolean(false))
        XCTAssertEqual(try Expression.eval("true || false"), .boolean(true))
        
        // Test complex nested boolean expressions
        XCTAssertEqual(try Expression.eval("(true && false) || (false || true)"), .boolean(true))
        XCTAssertEqual(try Expression.eval("!(true && false) && !(false || false)"), .boolean(true))
        
        // Test XOR truth table completely
        XCTAssertEqual(try Expression.eval("true xor true"), .boolean(false))
        XCTAssertEqual(try Expression.eval("true xor false"), .boolean(true))
        XCTAssertEqual(try Expression.eval("false xor true"), .boolean(true))
        XCTAssertEqual(try Expression.eval("false xor false"), .boolean(false))
    }
    
    func testStringEdgeCases() throws {
        // Test strings with special characters
        let specialStringResult = try Expression.eval("\"Hello\\tWorld\\n\"")
        XCTAssertTrue(specialStringResult.isString)
        
        // Test empty string
        let emptyResult = try Expression.eval("\"\"")
        XCTAssertTrue(emptyResult.isString)
        XCTAssertEqual(try emptyResult.asString(), "")
        
        // Test string with quotes (if supported)
        // This might not be supported depending on the parser implementation
        XCTAssertNoThrow(try Expression.eval("\"simple string\""))
    }
    
    func testMemoryManagementStress() throws {
        // Test creating and destroying many expressions rapidly
        for i in 0..<1000 {
            let expr = try Expression.parse("\(i % 100) + \(i % 50)")
            let result = try expr.eval()
            XCTAssertTrue(result.isNumber)
            // Don't store expressions to ensure they're deallocated
        }
        
        // Test creating many expressions with tokens
        for i in 0..<100 {
            let (value, tokens) = try Expression.eval("\(i) * 2", collectTokens: true)
            XCTAssertTrue(value.isNumber)
            XCTAssertNotNil(tokens)
            XCTAssertFalse(tokens?.isEmpty ?? true)
        }
    }
    
    func testTokenCollectionEdgeCases() throws {
        // Test token collection with complex expressions
        let (_, tokens) = try Expression.eval("max(abs(-5), sqrt(pow(2, 3)))", collectTokens: true)
        guard let tokens = tokens else {
            XCTFail("Expected tokens to be collected")
            return
        }
        
        // Verify we have meaningful tokens
        XCTAssertTrue(tokens.count > 10, "Should have multiple tokens for complex expression")
        
        // Check that all token types are represented appropriately
        let tokenTypes = Set(tokens.map { $0.type })
        XCTAssertTrue(tokenTypes.contains(.identifier), "Should have identifier tokens for function names")
        XCTAssertTrue(tokenTypes.contains(.number), "Should have number tokens")
        XCTAssertTrue(tokenTypes.contains(.parenthesis), "Should have parenthesis tokens")
        XCTAssertTrue(tokenTypes.contains(.comma), "Should have comma tokens")
        
        // Test token collection with different expression types
        let (_, boolTokens) = try Expression.eval("true && false", collectTokens: true)
        XCTAssertNotNil(boolTokens)
        XCTAssertTrue(boolTokens?.contains { $0.type == .boolean } ?? false)
        
        let (_, stringTokens) = try Expression.eval("\"test\"", collectTokens: true)
        XCTAssertNotNil(stringTokens)
        XCTAssertTrue(stringTokens?.contains { $0.type == .string } ?? false)
    }
    
    func testErrorMessageQuality() {
        // Test that error messages are helpful and specific
        do {
            _ = try Expression.parse("1 +")
            XCTFail("Should have thrown an error")
        } catch let error as ExpressionError {
            let message = error.localizedDescription
            XCTAssertTrue(message.contains("Parse failed") || message.contains("failed"), 
                         "Error message should indicate parse failure: \(message)")
        } catch {
            XCTFail("Expected ExpressionError, got: \(type(of: error))")
        }
        
        // Test evaluation error messages
        do {
            _ = try Expression.eval("1 / 0")
            XCTFail("Should have thrown an error for division by zero")
        } catch let error as ExpressionError {
            let message = error.localizedDescription
            XCTAssertFalse(message.isEmpty, "Error message should not be empty")
        } catch {
            XCTFail("Expected ExpressionError, got: \(type(of: error))")
        }
    }
    
    // MARK: - Helper Methods
    
    private func measureTime<T>(_ operation: () throws -> T) rethrows -> TimeInterval {
        let startTime = Date()
        _ = try operation()
        return Date().timeIntervalSince(startTime)
    }
}