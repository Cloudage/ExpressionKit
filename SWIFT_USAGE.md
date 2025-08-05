# ExpressionKit Swift Support

This document describes how to use ExpressionKit from Swift, including the new token sequence analysis features.

## Adding ExpressionKit to Your Swift Project

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Cloudage/ExpressionKit.git", from: "1.0.0")
]
```

Or add it via Xcode: File → Add Package Dependencies, then enter the repository URL.

## Quick Start

### Basic Usage

```swift
import ExpressionKit

// Simple arithmetic
let result = try Expression.eval("2 + 3 * 4")
print(result) // .number(14.0)

// Boolean expressions
let boolResult = try Expression.eval("true && false")
print(boolResult) // .boolean(false)

// String expressions
let stringResult = try Expression.eval("\"Hello, World!\"")
print(stringResult) // "Hello, World!"
```

### Parse Once, Execute Many Times

One of the key features of ExpressionKit is the ability to parse an expression once and execute it multiple times efficiently:

```swift
import ExpressionKit

// Parse the expression once
let expression = try Expression.parse("(a + b) * c - 1")

// Execute many times (very efficient)
for i in 0..<10000 {
    let result = try expression.eval()
    print(result) // Same result each time: .number(some_value)
}
```

This is much more efficient than parsing the expression every time.

## 🎨 Token Sequence Analysis

ExpressionKit now supports token sequence collection for advanced features like syntax highlighting, error reporting, and IDE integration.

### Token Types

The Swift API provides the following token types:

```swift
public enum TokenType: Int {
    case number = 0        // Numeric literals: 42, 3.14, -2.5
    case boolean = 1       // Boolean literals: true, false
    case string = 2        // String literals: "hello", "world", ""
    case identifier = 3    // Variables and functions: x, sqrt, player_health
    case operator = 4      // Operators: +, -, *, /, ==, !=, &&, ||, !
    case parenthesis = 5   // Grouping: (, )
    case comma = 6         // Function separator: ,
    case whitespace = 7    // Spaces and tabs
    case unknown = 8       // Unrecognized tokens
}
```

### Token Structure

Each token contains position and type information:

```swift
public struct Token {
    public let type: TokenType     // Type of the token
    public let start: Int          // Starting position in source text
    public let length: Int         // Length of the token
    public let text: String        // The actual token text
}
```

### Collecting Tokens During Evaluation

```swift
import ExpressionKit

// Evaluate with token collection
let (value, tokens) = try Expression.eval("2 + 3 * max(4, 5)", collectTokens: true)
print("Result: \(value)")

if let tokens = tokens {
    for token in tokens {
        print("Token: \(token.type) '\(token.text)' at \(token.start):\(token.length)")
    }
}

// String expression with tokens
let (stringValue, stringTokens) = try Expression.eval("\"Hello, ExpressionKit!\"", collectTokens: true)
print("String result: \(stringValue)")

if let tokens = stringTokens {
    for token in tokens {
        print("String token: \(token.type) '\(token.text)' at \(token.start):\(token.length)")
    }
}

// Output example:
// Result: .number(17.0)
// Token: number '2' at 0:1
// Token: operator '+' at 2:1
// Token: number '3' at 4:1
// Token: operator '*' at 6:1
// Token: identifier 'max' at 8:3
// Token: parenthesis '(' at 11:1
// Token: number '4' at 12:1
// Token: comma ',' at 13:1
// Token: number '5' at 15:1
// Token: parenthesis ')' at 16:1
// String result: "Hello, ExpressionKit!"
// String token: string '"Hello, ExpressionKit!"' at 0:23
```

### Collecting Tokens During Parsing

For pre-compiled expressions, you can collect tokens during parsing:

```swift
import ExpressionKit

// Parse with token collection
let (expression, tokens) = try Expression.parse("(x + y) * z", collectTokens: true)

if let tokens = tokens {
    print("Parsed \(tokens.count) tokens:")
    for token in tokens {
        print("  \(token.type): '\(token.text)'")
    }
}

// Later execute the pre-compiled expression (multiple times if needed)
// Note: Variable execution requires environment support (coming in future versions)
```

### Use Cases for Token Sequences

- **🎨 Syntax Highlighting**: Color-code different token types in your app
  ```swift
  for token in tokens {
      switch token.type {
      case .number: applyColor(.blue, to: token)
      case .operator: applyColor(.red, to: token)
      case .identifier: applyColor(.green, to: token)
      case .boolean: applyColor(.purple, to: token)
      case .string: applyColor(.orange, to: token)
      default: break
      }
  }
  ```

- **🔍 Error Reporting**: Provide precise error locations
  ```swift
  func validateExpression(_ expr: String) -> [ValidationError] {
      do {
          let (_, tokens) = try Expression.eval(expr, collectTokens: true)
          // Analyze tokens for potential issues
          return analyzeTokens(tokens)
      } catch {
          return [ValidationError(message: error.localizedDescription)]
      }
  }
  ```

- **🤖 Auto-completion**: Build intelligent code completion
  ```swift
  func getSuggestions(for tokens: [Token], at position: Int) -> [String] {
      // Analyze context from tokens to provide relevant suggestions
      if let lastToken = tokens.last, lastToken.type == .identifier {
          return ["sqrt", "max", "min", "abs", "sin", "cos"]
      }
      return []
  }
  ```

- **📊 Expression Analysis**: Understand expression complexity
  ```swift
  func analyzeComplexity(_ tokens: [Token]) -> ExpressionStats {
      let operators = tokens.filter { $0.type == .operator }.count
      let functions = tokens.filter { $0.type == .identifier }.count
      let depth = calculateNestingDepth(tokens)
      
      return ExpressionStats(operators: operators, functions: functions, depth: depth)
  }
  ```

## Supported Syntax

### Data Types
- **Numbers**: `42`, `3.14`, `-2.5`
- **Booleans**: `true`, `false`
- **Strings**: `"hello"`, `"world"`, `""`

### Operators (by precedence)

| Precedence | Operator | Description | Example |
|----------|---------|-------------|---------|
| 1 | `()` | Grouping | `(a + b) * c` |
| 2 | `!`, `not`, `-` | Unary operators | `!flag`, `not visible`, `-value` |
| 3 | `*`, `/` | Multiplication/Division | `a * b`, `x / y` |
| 4 | `+`, `-` | Addition/Subtraction | `a + b`, `x - y` |
| 5 | `<`, `>`, `<=`, `>=` | Relational comparison | `5 >= 3`, `score < 100` |
| 6 | `==`, `!=` | Equality comparison | `name == value`, `id != 0` |
| 7 | `xor` | Logical XOR | `a xor b` |
| 8 | `&&`, `and` | Logical AND | `a && b`, `x and y` |
| 9 | `\|\|`, `or` | Logical OR | `a \|\| b`, `x or y` |

## Value Type

ExpressionKit uses a `Value` enum that can represent either numbers or booleans:

```swift
// Creating values
let num: Value = .number(42.0)
let bool: Value = .boolean(true)
let str: Value = .string("hello")

// Or using literals
let num2: Value = 42.0
let bool2: Value = true
let str2: Value = "hello"

// Checking types
print(num.isNumber)   // true
print(num.isBoolean)  // false
print(str.isString)   // true

// Accessing values safely
let numberValue = try num.asNumber()  // 42.0
let boolValue = try bool.asBoolean()  // true
let stringValue = try str.asString()  // "hello"

// Or accessing optionally
let maybeNumber = num.numberValue     // Optional(42.0)
let maybeBool = num.booleanValue      // nil
let maybeString = str.stringValue     // Optional("hello")
```

## Error Handling

ExpressionKit uses Swift's error handling system:

```swift
do {
    let result = try Expression.eval("2 + 3")
    print("Result: \\(result)")
} catch let error as ExpressionError {
    print("Expression error: \\(error.localizedDescription)")
} catch {
    print("Unexpected error: \\(error)")
}
```

Error types:
- `ExpressionError.parseFailed`: Invalid expression syntax
- `ExpressionError.evaluationFailed`: Runtime evaluation error (e.g., division by zero)
- `ExpressionError.typeMismatch`: Type conversion error
- `ExpressionError.environmentError`: Variable or function access error

## Advanced Examples

### Complex Expressions

```swift
// Complex arithmetic with precedence
let result1 = try Expression.eval("2 + 3 * 4 - 1")  // 13.0

// Boolean logic
let result2 = try Expression.eval("true && (false || true)")  // true

// String expressions
let result2_5 = try Expression.eval("\"Hello, World!\"")  // "Hello, World!"

// Comparisons
let result3 = try Expression.eval("(5 + 3) > (2 * 3)")  // true (8 > 6)

// Mixed operations
let result4 = try Expression.eval("5 > 3 && 2 == 2")  // true
```

### Performance Characteristics

Token collection has minimal overhead compared to regular evaluation:

```swift
// Performance comparison example
let expression = "((2 + 3) * 4 - 1) / (5 + 2) >= 1.5 && true"

// Without tokens: ~0.5ms per evaluation
let start1 = Date()
for _ in 0..<1000 {
    _ = try! Expression.eval(expression)
}
let timeWithoutTokens = Date().timeIntervalSince(start1)

// With tokens: ~0.55ms per evaluation
let start2 = Date()
for _ in 0..<1000 {
    _ = try! Expression.eval(expression, collectTokens: true)
}
let timeWithTokens = Date().timeIntervalSince(start2)

print("Overhead: \((timeWithTokens/timeWithoutTokens - 1) * 100)%") // ~10%
```

The overhead is primarily from token text allocation. For performance-critical code paths, collect tokens only when needed.

## Future Enhancements

The current Swift implementation provides the core "parse once, execute many times" functionality with support for:
- ✅ All arithmetic operators
- ✅ All logical operators  
- ✅ All comparison operators
- ✅ Parentheses grouping
- ✅ Type-safe Value system
- ✅ Error handling

Future versions may add:
- 🔄 Variable and function support via environments
- 🔄 Built-in mathematical functions (sin, cos, sqrt, etc.)
- 🔄 String operations and concatenation functions
- 🔄 Custom function registration
- 🔄 **Array and Dictionary support** - See [implementation analysis](ARRAY_DICTIONARY_SUPPORT_EN.md) for detailed technical plans

## C++ Compatibility

This Swift API is built on top of the existing C++ ExpressionKit library, so it maintains full compatibility with the C++ implementation while providing a clean, Swift-native interface.

## Migration from C++

If you're migrating from the C++ version:

| C++ | Swift |
|-----|-------|
| `ExpressionKit::Eval("2+3")` | `try Expression.eval("2+3")` |
| `ExpressionKit::Parse("2+3")` | `try Expression.parse("2+3")` |
| `ast->evaluate(environment)` | `try expression.eval()` |
| `Value(42.0)` | `Value.number(42.0)` or `42.0` |
| `Value(true)` | `Value.boolean(true)` or `true` |
| `Value("hello")` | `Value.string("hello")` or `"hello"` |