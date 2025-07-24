import ExpressionKit
import Foundation

// Function to print token information
func printTokens(_ tokens: [Token], for expression: String) {
    print("\n" + String(repeating: "=", count: 60))
    print("Expression: \(expression)")
    print(String(repeating: "=", count: 60))
    
    print("Tokens collected (\(tokens.count) total):")
    print(String(format: "%-12s %-8s %-8s %s", "Type", "Start", "Length", "Text"))
    print(String(repeating: "-", count: 60))
    
    for token in tokens {
        let typeName = String(describing: token.type).uppercased()
        print(String(format: "%-12s %-8d %-8d \"%s\"", 
                     typeName, token.start, token.length, token.text))
    }
}

print("🚀 ExpressionKit Swift Token Demo")
print("==================================")
print("\nThis demo shows how to collect token sequences during expression")
print("parsing for syntax highlighting, analysis, and other advanced features.")

// Test basic functionality with the new lightweight Value system
print("\n📝 Testing basic functionality...")

// Test basic arithmetic - Value now directly uses ExprValue
let result1 = try! Expression.evaluate("2 + 3 * 4")
print("2 + 3 * 4 = \(result1)") // Should print: 14.0

// Test boolean operations
let result2 = try! Expression.evaluate("true && false || true")
print("true && false || true = \(result2)") // Should print: true

// Test parse once, execute many times
let expression = try! Expression.parse("(5 + 3) * 2 - 1")
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

print("\n🎯 Now demonstrating TOKEN SEQUENCE functionality...")

// Basic arithmetic expression with tokens
do {
    let (value, tokens) = try Expression.evaluate("2 + 3 * 4", collectTokens: true)
    print("Result: \(value)")
    if let tokens = tokens {
        printTokens(tokens, for: "2 + 3 * 4")
    }
} catch {
    print("Error: \(error)")
}

// Boolean expression with tokens
do {
    let (value, tokens) = try Expression.evaluate("true && (false || !true)", collectTokens: true)
    print("Result: \(value)")
    if let tokens = tokens {
        printTokens(tokens, for: "true && (false || !true)")
    }
} catch {
    print("Error: \(error)")
}

// Complex expression with parentheses
do {
    let (value, tokens) = try Expression.evaluate("(10 + 5) * 2 - 3", collectTokens: true)
    print("Result: \(value)")
    if let tokens = tokens {
        printTokens(tokens, for: "(10 + 5) * 2 - 3")
    }
} catch {
    print("Error: \(error)")
}

// Mathematical functions with tokens
do {
    let (value, tokens) = try Expression.evaluate("max(10, 5) + sqrt(16)", collectTokens: true)
    print("Result: \(value)")
    if let tokens = tokens {
        printTokens(tokens, for: "max(10, 5) + sqrt(16)")
    }
} catch {
    print("Error: \(error)")
}

// Demonstrate parsing with tokens (for pre-compilation scenarios)
print("\n📋 Parse-once, execute-many with tokens:")
do {
    let (_, tokens) = try Expression.parse("(a + b) * c - 1", collectTokens: true)
    print("Parsed successfully!")
    if let tokens = tokens {
        printTokens(tokens, for: "(a + b) * c - 1")
    }
    
    // Note: We can't execute this because we don't have environment support in Swift yet
    print("Note: Execution with variables requires environment support (coming in future versions)")
} catch {
    print("Parse error: \(error)")
}

// Performance comparison: with and without tokens
print("\n⚡ Performance comparison:")
let complexExpr = "((2 + 3) * 4 - 1) / (5 + 2) >= 1.5 && true"

let startTime1 = Date()
for _ in 0..<1000 {
    _ = try! Expression.evaluate(complexExpr)
}
let time1 = Date().timeIntervalSince(startTime1)

let startTime2 = Date()
for _ in 0..<1000 {
    _ = try! Expression.evaluate(complexExpr, collectTokens: true)
}
let time2 = Date().timeIntervalSince(startTime2)

print("1000 evaluations without tokens: \(String(format: "%.4f", time1))s")
print("1000 evaluations with tokens: \(String(format: "%.4f", time2))s")
print("Token collection overhead: \(String(format: "%.1f", (time2/time1 - 1) * 100))%")

print("\n" + String(repeating: "=", count: 60))
print("🎯 Use Cases for Token Sequences:")
print("• Syntax highlighting in code editors")
print("• Expression validation and error reporting")
print("• Auto-completion for variables and functions")
print("• Expression formatting and pretty-printing")
print("• Static analysis and optimization")
print("• IDE integration and debugging tools")
print(String(repeating: "=", count: 60))

print("\n✅ All functionality preserved with lightweight architecture!")
print("🚀 Token sequence feature now fully demonstrated!")