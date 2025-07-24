# ExpressionKit Swift Support

This document describes how to use ExpressionKit from Swift.

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
let result = try ExpressionKit.evaluate("2 + 3 * 4")
print(result) // .number(14.0)

// Boolean expressions
let boolResult = try ExpressionKit.evaluate("true && false")
print(boolResult) // .boolean(false)
```

### Parse Once, Execute Many Times

One of the key features of ExpressionKit is the ability to parse an expression once and execute it multiple times efficiently:

```swift
import ExpressionKit

// Parse the expression once
let expression = try ExpressionKit.parse("(a + b) * c - 1")

// Execute many times (very efficient)
for i in 0..<10000 {
    let result = try expression.evaluate()
    print(result) // Same result each time: .number(some_value)
}
```

This is much more efficient than parsing the expression every time.

## Supported Syntax

### Data Types
- **Numbers**: `42`, `3.14`, `-2.5`
- **Booleans**: `true`, `false`

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

// Or using literals
let num2: Value = 42.0
let bool2: Value = true

// Checking types
print(num.isNumber)   // true
print(num.isBoolean)  // false

// Accessing values safely
let numberValue = try num.asNumber()  // 42.0
let boolValue = try bool.asBoolean()  // true

// Or accessing optionally
let maybeNumber = num.numberValue     // Optional(42.0)
let maybeBool = num.booleanValue      // nil
```

## Error Handling

ExpressionKit uses Swift's error handling system:

```swift
do {
    let result = try ExpressionKit.evaluate("2 + 3")
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
- `ExpressionError.backendError`: Variable or function access error

## Advanced Examples

### Complex Expressions

```swift
// Complex arithmetic with precedence
let result1 = try ExpressionKit.evaluate("2 + 3 * 4 - 1")  // 13.0

// Boolean logic
let result2 = try ExpressionKit.evaluate("true && (false || true)")  // true

// Comparisons
let result3 = try ExpressionKit.evaluate("(5 + 3) > (2 * 3)")  // true (8 > 6)

// Mixed operations
let result4 = try ExpressionKit.evaluate("5 > 3 && 2 == 2")  // true
```

### High Performance Loop

```swift
// Parse complex expression once
let healthCheck = try ExpressionKit.parse("health > 0 && health <= maxHealth")
let damageCalc = try ExpressionKit.parse("(damage - armor) * multiplier")

// Game loop - execute thousands of times efficiently
for frame in 0..<10000 {
    // These execute very fast because parsing is already done
    let isAlive = try healthCheck.evaluate()    // Very fast
    let finalDamage = try damageCalc.evaluate() // Very fast
    
    // Game logic...
}
```

## Performance Characteristics

### Parse Once vs. Evaluate Every Time

```swift
// ❌ Slow: Parse every time
for i in 0..<10000 {
    let result = try ExpressionKit.evaluate("complex * expression + here")
}

// ✅ Fast: Parse once, execute many
let expression = try ExpressionKit.parse("complex * expression + here")
for i in 0..<10000 {
    let result = try expression.evaluate()
}
```

The second approach can be **orders of magnitude faster** for complex expressions executed repeatedly.

## Future Enhancements

The current Swift implementation provides the core "parse once, execute many times" functionality with support for:
- ✅ All arithmetic operators
- ✅ All logical operators  
- ✅ All comparison operators
- ✅ Parentheses grouping
- ✅ Type-safe Value system
- ✅ Error handling

Future versions may add:
- 🔄 Variable and function support via backends
- 🔄 Built-in mathematical functions (sin, cos, sqrt, etc.)
- 🔄 Custom function registration

## C++ Compatibility

This Swift API is built on top of the existing C++ ExpressionKit library, so it maintains full compatibility with the C++ implementation while providing a clean, Swift-native interface.

## Migration from C++

If you're migrating from the C++ version:

| C++ | Swift |
|-----|-------|
| `ExprTK::Eval("2+3")` | `try ExpressionKit.evaluate("2+3")` |
| `ExprTK::Parse("2+3")` | `try ExpressionKit.parse("2+3")` |
| `ast->evaluate(backend)` | `try expression.evaluate()` |
| `Value(42.0)` | `Value.number(42.0)` or `42.0` |
| `Value(true)` | `Value.boolean(true)` or `true` |