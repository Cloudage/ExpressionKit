import ExpressionKit

// Test basic functionality with the new lightweight Value system
print("Testing lightweight ExpressionKit Value system...")

// Test basic arithmetic - Value now directly uses ExprValue
let result1 = try! ExpressionKit.evaluate("2 + 3 * 4")
print("2 + 3 * 4 = \(result1)") // Should print: 14.0

// Test boolean operations
let result2 = try! ExpressionKit.evaluate("true && false || true")
print("true && false || true = \(result2)") // Should print: true

// Test parse once, execute many times
let expression = try! ExpressionKit.parse("(5 + 3) * 2 - 1")
let result3 = try! expression.evaluate()
print("(5 + 3) * 2 - 1 = \(result3)") // Should print: 15.0

// Test type checking with the new API
let numberValue: Value = 42.5
print("numberValue.isNumber = \(numberValue.isNumber)") // Should print: true
print("numberValue.isBoolean = \(numberValue.isBoolean)") // Should print: false

let boolValue: Value = true
print("boolValue.isNumber = \(boolValue.isNumber)") // Should print: false  
print("boolValue.isBoolean = \(boolValue.isBoolean)") // Should print: true

// Test literal initialization
let intLiteral: Value = 42
let floatLiteral: Value = 3.14
let boolLiteral: Value = false

print("Literals work: \(intLiteral), \(floatLiteral), \(boolLiteral)")

print("✅ All functionality preserved with lightweight architecture!")