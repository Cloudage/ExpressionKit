import XCTest
@testable import ExpressionKit

final class ExpressionKitTests: XCTestCase {
    
    func testBasicArithmetic() throws {
        // Test direct evaluation
        let result = try ExpressionKit.evaluate("2 + 3 * 4")
        XCTAssertEqual(result, .number(14.0))
    }
    
    func testBooleanExpression() throws {
        let result = try ExpressionKit.evaluate("true && false")
        XCTAssertEqual(result, .boolean(false))
        
        let result2 = try ExpressionKit.evaluate("true || false")
        XCTAssertEqual(result2, .boolean(true))
    }
    
    func testParseOnceExecuteMany() throws {
        // Parse once
        let expression = try ExpressionKit.parse("2 + 3 * 4")
        
        // Execute multiple times
        for _ in 0..<1000 {
            let result = try expression.evaluate()
            XCTAssertEqual(result, .number(14.0))
        }
    }
    
    func testComplexArithmetic() throws {
        let result = try ExpressionKit.evaluate("(2 + 3) * 4 - 1")
        XCTAssertEqual(result, .number(19.0)) // (2 + 3) * 4 - 1 = 5 * 4 - 1 = 20 - 1 = 19
    }
    
    func testBooleanLogic() throws {
        let result1 = try ExpressionKit.evaluate("true && true")
        XCTAssertEqual(result1, .boolean(true))
        
        let result2 = try ExpressionKit.evaluate("false || true")
        XCTAssertEqual(result2, .boolean(true))
        
        let result3 = try ExpressionKit.evaluate("!false")
        XCTAssertEqual(result3, .boolean(true))
        
        let result4 = try ExpressionKit.evaluate("true xor false")
        XCTAssertEqual(result4, .boolean(true))
    }
    
    func testComparison() throws {
        let result1 = try ExpressionKit.evaluate("5 > 3")
        XCTAssertEqual(result1, .boolean(true))
        
        let result2 = try ExpressionKit.evaluate("2 == 2")
        XCTAssertEqual(result2, .boolean(true))
        
        let result3 = try ExpressionKit.evaluate("4 <= 4")
        XCTAssertEqual(result3, .boolean(true))
    }
    
    func testParseOnceComplex() throws {
        // Parse once
        let expression = try ExpressionKit.parse("(5 + 3) * 2 - 1")
        
        // Execute multiple times with same result
        for _ in 0..<100 {
            let result = try expression.evaluate()
            XCTAssertEqual(result, .number(15.0)) // (5 + 3) * 2 - 1 = 8 * 2 - 1 = 16 - 1 = 15
        }
    }
    
    func testErrorHandling() {
        // Test parse error
        XCTAssertThrowsError(try ExpressionKit.parse("1 + * 3")) { error in
            XCTAssertTrue(error is ExpressionError)
        }
        
        // Test evaluation error
        XCTAssertThrowsError(try ExpressionKit.evaluate("1 / 0")) { error in
            XCTAssertTrue(error is ExpressionError)
        }
    }
    
    func testValueTypes() throws {
        // Test number value
        let numValue: Value = .number(42.0)
        XCTAssertTrue(numValue.isNumber)
        XCTAssertFalse(numValue.isBoolean)
        XCTAssertEqual(try numValue.asNumber(), 42.0)
        XCTAssertEqual(numValue.numberValue, 42.0)
        
        // Test boolean value
        let boolValue: Value = .boolean(true)
        XCTAssertFalse(boolValue.isNumber)
        XCTAssertTrue(boolValue.isBoolean)
        XCTAssertEqual(try boolValue.asBoolean(), true)
        XCTAssertEqual(boolValue.booleanValue, true)
        
        // Test type errors
        XCTAssertThrowsError(try numValue.asBoolean())
        XCTAssertThrowsError(try boolValue.asNumber())
    }
    
    func testValueLiterals() {
        let intLiteral: Value = 42
        XCTAssertEqual(intLiteral, .number(42.0))
        
        let floatLiteral: Value = 3.14
        XCTAssertEqual(floatLiteral, .number(3.14))
        
        let boolLiteral: Value = true
        XCTAssertEqual(boolLiteral, .boolean(true))
    }
}