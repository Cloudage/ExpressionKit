# ExpressionKit

A lightweight, interface-driven C++ expression parsing and evaluation library with Swift and Kotlin support and token sequence analysis

## 🚀 Key Features

- **Interface-based variable read/write**: Flexible access to variables and functions via the IEnvironment interface  
- **Pre-parsed AST execution**: Supports expression pre-compilation for efficient repeated execution
- **Token sequence analysis**: Optional token collection for syntax highlighting and advanced features
- **Type safety**: Strongly-typed Value system supporting numeric, boolean, and string types
- **Complete operator support**: Full coverage of arithmetic, comparison, and logical operators
- **Exception-based error handling**: Clear error messages and robust exception mechanism
- **Zero dependencies**: Depends only on the C++ standard library
- **Multi-Language Support**: Clean APIs for C++, Swift (with SPM), and Kotlin (with Gradle)

### 🎯 Quick Start - Try the Demos!

**Want to see ExpressionKit in action?** Jump straight to our interactive examples:

| Target | Description | Command |
|--------|-------------|---------|
| 🖥️ **ExpressionDemo** | Interactive CLI with syntax highlighting | `cd CPP && cmake . && make ExpressionDemo && ./ExpressionDemo` |
| 🧪 **ExprTKTest** | Comprehensive unit test suite | `cd CPP && cmake . && make ExprTKTest && ./ExprTKTest` |
| 🎨 **TokenDemo** | Token analysis for syntax highlighting | `cd CPP && cmake . && make TokenDemo && ./TokenDemo` |
| 🍎 **Swift Example** | Swift API demonstration | `cd Swift/Examples/SwiftExample && swift run` |
| ☕ **Kotlin Tests** | Kotlin JUnit test suite | `cd Kotlin && gradle test` |

➡️ **[See detailed instructions below](#quick-start---try-the-demos)**

## 🧪 Test Status

[![Test Status Check](https://github.com/Cloudage/ExpressionKit/actions/workflows/test-status-check.yml/badge.svg)](https://github.com/Cloudage/ExpressionKit/actions/workflows/test-status-check.yml)

### Automated Testing

This repository uses automated testing with GitHub Actions to ensure code quality and reliability:

- **C++ Core Library**: Comprehensive testing using Catch2 framework (28 test cases, 332 assertions)
- **Swift Wrapper**: Testing via XCTest framework with Swift Package Manager (60 test methods)
- **Kotlin Implementation**: Testing via JUnit framework with Gradle (39 test methods)

**Testing Parity Principle**: All language implementations maintain equivalent comprehensive test coverage to ensure behavioral consistency across C++, Swift, and Kotlin. See [TESTING_PARITY.md](TESTING_PARITY.md) for detailed coverage analysis and parity standards.

**View Latest Test Results**: Click the badge above or visit the [Actions tab](https://github.com/Cloudage/ExpressionKit/actions/workflows/test-status-check.yml) to see detailed test results, including test counts, assertions, and execution summaries.

### Running Tests Locally

ExpressionKit includes comprehensive test suites and interactive demos for C++, Swift, and Kotlin:

```bash
# Run all tests (C++, Swift, and Kotlin)
./scripts/run_all_tests.sh

# Run individual test suites
./scripts/run_cpp_tests.sh      # C++ tests only
./scripts/run_swift_tests.sh    # Swift tests only
./scripts/run_kotlin_tests.sh   # Kotlin tests only
```

**💡 Want to try the interactive demos?** See the [Demo & Test Targets section](#-try-it-live---demo--test-targets) below for hands-on examples!

## 🏗️ Development Approach for Multi-Language Support

**ExpressionKit follows a 1:1 translation approach for language support**, ensuring consistent behavior across all implementations:

### Core Philosophy
- **Single Source of Truth**: The C++ `ExpressionKit.hpp` serves as the reference implementation
- **1:1 Algorithm Translation**: Each language implementation translates the exact same algorithms, logic, and behavior 
- **API Consistency**: While using language-idiomatic patterns, all implementations provide equivalent functionality
- **Test Parity**: Unit tests are translated to match the C++ test suite, ensuring identical behavior

### Language Implementation Process
When adding support for new languages, follow this structured approach:

1. **Start with ExpressionKit.hpp**: Study the C++ implementation thoroughly
   - Understand the AST node hierarchy
   - Learn the parser's recursive descent structure  
   - Map out the operator precedence and evaluation rules
   - Study the Value type system and conversion rules

2. **Create 1:1 Translation**: Implement each component systematically
   - **Value System**: Translate the type-safe Value struct with conversion rules
   - **AST Nodes**: Create equivalent node classes (NumberNode, BinaryOpNode, etc.)
   - **Parser**: Implement recursive descent parser with identical precedence rules
   - **Environment Interface**: Provide the IEnvironment abstraction pattern
   - **Built-in Functions**: Include all standard mathematical functions

3. **Maintain API Compatibility**: Ensure the target language feels natural
   - Use language conventions (naming, error handling, etc.)
   - Provide idiomatic factory methods and convenience APIs
   - Include backward compatibility layers when needed

4. **Comprehensive Testing**: Translate the complete C++ test suite
   - Convert all unit tests to the target language
   - Verify identical behavior for edge cases
   - Test performance characteristics match expectations

### Example: Swift Implementation
The Swift implementation demonstrates this approach:

```swift
// Pure Swift implementation translated 1:1 from C++ ExpressionKit.hpp
// - Same AST structure and evaluation algorithms
// - Identical operator precedence and parsing rules  
// - Equivalent Value type system and conversion behavior
// - All built-in mathematical functions included
// - Complete backward compatibility with previous Swift API

let result = try Expression.eval("2 + 3 * 4")  // Same behavior as C++
let compiled = try Expression.parse("x + sqrt(y)")  // Same performance benefits
```

### Benefits of This Approach
- **Consistent Behavior**: All language implementations behave identically
- **Predictable Results**: Expressions evaluate the same way across languages
- **Maintainability**: Bug fixes and features propagate easily across implementations
- **Quality Assurance**: Comprehensive test coverage ensures reliability
- **Performance**: Each implementation can be optimized for its target language

This ensures developers can confidently use ExpressionKit across different platforms and languages, knowing they'll get consistent, reliable expression evaluation everywhere.

## 🤖 AI-Generated Code Notice

**Important: The code in this project is primarily generated by AI tools (e.g., GitHub Copilot), under human guidance and review.**

The code follows modern language best practices and provides a clean, interface-based expression evaluation system.

## 🛠️ Setup & Installation

### For Swift Projects (Recommended)

ExpressionKit can be easily integrated into Swift projects using **Swift Package Manager**:

#### Option 1: Xcode Integration
1. Open your Xcode project
2. Go to **File** → **Add Package Dependencies**
3. Enter repository URL: `https://github.com/Cloudage/ExpressionKit.git`
4. Select version (from `1.0.0`)

#### Option 2: Package.swift
Add to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/Cloudage/ExpressionKit.git", from: "1.0.0")
]
```

Then import and use:

```swift
import ExpressionKit

// Direct evaluation
let result = try Expression.eval("2 + 3 * 4")  // 14.0

// Parse once, execute many times (high performance)
let expression = try Expression.parse("(a + b) * c - 1")
for _ in 0..<10000 {
    let result = try expression.eval()  // Very fast!
}
```

**📖 For complete Swift documentation, see [SWIFT_USAGE.md](SWIFT_USAGE.md)**

### For Kotlin/JVM Projects

For Kotlin projects, add ExpressionKit to your Gradle dependencies:

```kotlin
// build.gradle.kts
dependencies {
    implementation("com.expressionkit:expressionkit:1.0.0")
}
```

```kotlin
import com.expressionkit.*

// Simple evaluation
val result = Expression.eval("2 + 3 * 4") // Returns Value.number(14.0)

// With variables and custom functions
val env = SimpleEnvironment()
env.setVariable("x", 10.0)
env.setFunction("double") { args -> Value.number(args[0].asNumber() * 2) }

val result = Expression.eval("double(x) + 5", env) // Returns Value.number(25.0)

// Pre-compiled expressions for performance
val compiled = Expression.parse("health > maxHealth * 0.5")
val isHealthy = compiled.evaluate(env) // Very fast repeated evaluation!
```

**📖 For complete Kotlin documentation, see [KOTLIN_USAGE.md](KOTLIN_USAGE.md)**

### For C++ Projects

For C++ projects, simply **copy the single header file** `ExpressionKit.hpp` to your project:

1. **Download**: Copy `ExpressionKit.hpp` from this repository
2. **Include**: Add `#include "ExpressionKit.hpp"` to your C++ files
3. **Compile**: Requires C++11 or later, no external dependencies

```cpp
#include "ExpressionKit.hpp"
using namespace ExpressionKit;

// Evaluate simple math expressions
auto result = Expression::Eval("2 + 3 * 4");  // Returns 14.0
std::cout << "Result: " << result.asNumber() << std::endl;

// Boolean expressions
auto boolResult = Expression::Eval("true && false");  // Returns false
std::cout << "Boolean result: " << boolResult.asBoolean() << std::endl;

// Token sequence collection for syntax highlighting
std::vector<Token> tokens;
auto resultWithTokens = Expression::Eval("2 + 3 * max(4, 5)", nullptr, &tokens);
std::cout << "Result: " << resultWithTokens.asNumber() << std::endl;
for (const auto& token : tokens) {
    std::cout << "Token: " << (int)token.type << " '" << token.text 
              << "' at " << token.start << ":" << token.length << std::endl;
}
```

## 📊 Quick Comparison

| Feature | Swift | C++ |
|---------|-------|-----|
| **Setup** | Swift Package Manager | Copy single .hpp file |
| **Dependencies** | None (handled by SPM) | None (header-only) |
| **Integration** | `import ExpressionKit` | `#include "ExpressionKit.hpp"` |
| **API** | `Expression.eval()` | `Expression::Eval()` |
| **Performance** | ✅ Full performance | ✅ Full performance |
| **Features** | ✅ All core features | ✅ All features + Environment |

### Which Version Should I Use?

- **🎯 Swift Projects**: Use Swift Package Manager integration for clean, type-safe API
- **🔧 C++ Projects**: Copy `ExpressionKit.hpp` for zero-dependency, header-only solution  
- **🏗️ Mixed Projects**: Both can coexist - same expression syntax and behavior

## 🎨 Token Sequence Analysis

ExpressionKit provides powerful token sequence analysis capabilities for syntax highlighting, IDE integration, and advanced expression analysis.

### Token Types

The library identifies the following token types during parsing:

| Token Type | Description | Examples |
|------------|-------------|----------|
| `NUMBER` | Numeric literals | `42`, `3.14`, `-2.5` |
| `BOOLEAN` | Boolean literals | `true`, `false` |
| `STRING` | String literals | `"hello"`, `"world"`, `""` |
| `IDENTIFIER` | Variables and function names | `x`, `pos.x`, `sqrt`, `player_health` |
| `OPERATOR` | All operators | `+`, `-`, `*`, `/`, `==`, `!=`, `&&`, `\|\|`, `!` |
| `PARENTHESIS` | Grouping symbols | `(`, `)` |
| `COMMA` | Function argument separator | `,` |
| `WHITESPACE` | Spaces and tabs | ` `, `\t` |
| `UNKNOWN` | Unrecognized tokens | (used for error handling) |

### C++ Token Collection

```cpp
#include "ExpressionKit.hpp"
using namespace ExpressionKit;

// Collect tokens during evaluation
std::vector<Token> tokens;
auto result = Expression::Eval("max(x + 5, y * 2)", &environment, &tokens);

// Process tokens for syntax highlighting
for (const auto& token : tokens) {
    std::cout << "Type: " << (int)token.type 
              << " Text: '" << token.text << "'" 
              << " Position: " << token.start << "-" << (token.start + token.length)
              << std::endl;
}

// Alternative: Parse with tokens for pre-compilation
std::vector<Token> parseTokens;
auto ast = Expression::Parse("complex_expression", &parseTokens);
// parseTokens now contains all tokens for syntax highlighting
auto result = ast->evaluate(&environment);
```

### Swift Token Collection

```swift
import ExpressionKit

// Evaluate with token collection
let (value, tokens) = try Expression.eval("max(x + 5, y * 2)", collectTokens: true)
print("Result: \(value)")

if let tokens = tokens {
    for token in tokens {
        print("Type: \(token.type), Text: '\(token.text)', Position: \(token.start)-\(token.start + token.length)")
    }
}

// Parse with token collection for pre-compilation
let (expression, parseTokens) = try Expression.parse("complex_expression", collectTokens: true)
// parseTokens contains all tokens for analysis
let result = try expression.eval()
```

### Use Cases for Token Sequences

- **🎨 Syntax Highlighting**: Color-code different token types in code editors
- **🔍 Error Reporting**: Precise error location and context information
- **✅ Expression Validation**: Check syntax before evaluation
- **🤖 Auto-completion**: Suggest variables and functions based on context
- **📝 Code Formatting**: Pretty-print expressions with proper spacing
- **🔧 Static Analysis**: Analyze expressions without execution
- **🏗️ IDE Integration**: Build advanced expression editing tools
- **📊 Expression Metrics**: Count operators, complexity analysis

### Performance Impact

Token collection has minimal performance overhead:

```cpp
// Benchmark: 1M evaluations of "2 + 3 * 4"
// Without tokens: ~50ms
// With tokens:    ~55ms
// Overhead:       ~10%
```

The overhead is primarily from string allocation for token text. For performance-critical applications, collect tokens only when needed (e.g., during development or for user-facing editors).

## 🎮 Try It Live - Demo & Test Targets

ExpressionKit provides several interactive examples and comprehensive tests that showcase its capabilities. Here's how to run them:

### 🖥️ Interactive C++ Demo

**ExpressionDemo** - A feature-rich interactive CLI with syntax highlighting:

```bash
# Build and run the interactive demo
cd CPP
cmake .
make ExpressionDemo
./ExpressionDemo
```

**Features:**
- Interactive expression evaluation with color syntax highlighting
- Variable management (set, delete, list)
- Support for all mathematical functions
- Real-time expression parsing and error reporting

**Example session:**
```
> set x 5 + 3           # Set x to 8
> set y x * 2           # Set y to 16 
> eval sin(pi/2)        # Evaluate sin(π/2) ≈ 1
> ls                    # Show all variables
```

### 🧪 C++ Unit Tests  

**ExprTKTest** - Comprehensive test suite powered by Catch2:

```bash
# Build and run all tests
cd CPP
cmake .
make ExprTKTest
./ExprTKTest

# Run specific test categories
./ExprTKTest [tag]           # Run tests with specific tag
./ExprTKTest --list-tags     # See available tags
```

### 🎨 Token Analysis Demo

**TokenDemo** - Advanced token sequence analysis for syntax highlighting:

```bash
# Build and run token demonstration
cd CPP
cmake .
make TokenDemo
./TokenDemo
```

Shows how to collect and analyze token sequences for:
- Syntax highlighting in editors
- Expression validation
- Auto-completion systems

### 🍎 Swift Example

**ExpressionKitExample** - Swift token demo and functionality showcase:

```bash
# Run Swift example with full token analysis
cd Swift/Examples/SwiftExample
swift run
```

**Features:**
- Demonstrates Swift API usage
- Token sequence collection examples
- Performance benchmarking
- Type safety demonstrations

---

## 🚀 Examples

### Swift Examples

```swift
import ExpressionKit

// Basic arithmetic
let result1 = try Expression.eval("2 + 3 * 4")  // 14.0

// Boolean logic
let result2 = try Expression.eval("true && (5 > 3)")  // true

// String expressions
let result2_5 = try Expression.eval("\"Hello, World!\"")  // "Hello, World!"

// Complex expressions
let result3 = try Expression.eval("(2 + 3) * 4 - 1")  // 19.0

// Parse once, execute many times for high performance
let expression = try Expression.parse("(a + b) * c - 1")
for _ in 0..<10000 {
    let result = try expression.eval()  // Very fast repeated execution
}

// Token sequence collection for syntax highlighting
let (value, tokens) = try Expression.eval("2 + 3 * max(4, 5)", collectTokens: true)
print("Result: \(value)")
if let tokens = tokens {
    for token in tokens {
        print("Token: \(token.type) '\(token.text)' at \(token.start):\(token.length)")
    }
}

// String token collection
let (stringValue, stringTokens) = try Expression.eval("\"Hello, ExpressionKit!\"", collectTokens: true)
print("String result: \(stringValue)")
if let tokens = stringTokens {
    for token in tokens {
        print("String token: \(token.type) '\(token.text)' at \(token.start):\(token.length)")
    }
}

// Error handling
do {
    let result = try Expression.eval("1 / 0")
} catch let error as ExpressionError {
    print("Expression error: \(error.localizedDescription)")
}
```

### Using IEnvironment for Variable Access (C++)

```cpp
#include "ExpressionKit.hpp"
#include <unordered_map>

class GameEnvironment : public ExpressionKit::IEnvironment {
private:
    std::unordered_map<std::string, ExpressionKit::Value> variables;
    
public:
    GameEnvironment() {
        // Initialize game state
        variables["health"] = 100.0;
        variables["maxHealth"] = 100.0;
        variables["level"] = 5.0;
        variables["isAlive"] = true;
        variables["pos.x"] = 10.5;
        variables["pos.y"] = 20.3;
    }
    
    // Implement variable reading
    ExpressionKit::Value Get(const std::string& name) override {
        auto it = variables.find(name);
        if (it == variables.end()) {
            throw ExpressionKit::ExprException("Variable not found: " + name);
        }
        return it->second;
    }
    
    // Implement function calls
    ExpressionKit::Value Call(const std::string& name, 
                             const std::vector<ExpressionKit::Value>& args) override {
        // Try standard mathematical functions first
        ExpressionKit::Value result;
        if (Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // Custom functions
        if (name == "distance" && args.size() == 4) {
            double x1 = args[0].asNumber(), y1 = args[1].asNumber();
            double x2 = args[2].asNumber(), y2 = args[3].asNumber();
            double dx = x2 - x1, dy = y2 - y1;
            return ExpressionKit::Value(std::sqrt(dx*dx + dy*dy));
        }
        throw ExpressionKit::ExprException("Unknown function: " + name);
    }
};

// Usage example
int main() {
    GameEnvironment environment;
    
    // Game logic expressions
    auto healthPercent = Expression::Eval("health / maxHealth", &environment);
    std::cout << "Health percentage: " << healthPercent.asNumber() << std::endl;
    
    // Complex condition checks
    auto needHealing = Expression::Eval("health < maxHealth * 0.5 && isAlive", &environment);
    std::cout << "Needs healing: " << (needHealing.asBoolean() ? "Yes" : "No") << std::endl;
    
    // Function calls
    auto playerPos = Expression::Eval("distance(pos.x, pos.y, 0, 0)", &environment);
    std::cout << "Distance from origin: " << playerPos.asNumber() << std::endl;
    
    return 0;
}
```

### High-Performance Execution with Pre-Parsed AST (C++)

A key feature of ExpressionKit is support for **pre-parsed ASTs**, allowing you to:
1. Parse expressions once
2. Execute them efficiently multiple times
3. Avoid repeated parsing overhead

```cpp
#include "ExpressionKit.hpp"

class HighPerformanceExample {
private:
    GameEnvironment environment;
    // Pre-compiled expression ASTs
    std::shared_ptr<ExpressionKit::ASTNode> healthCheckExpr;
    std::shared_ptr<ExpressionKit::ASTNode> damageCalcExpr;
    std::shared_ptr<ExpressionKit::ASTNode> levelUpExpr;
    
public:
    HighPerformanceExample() {
        // Pre-compile all expressions at startup
        healthCheckExpr = Expression::Parse("health > 0 && health <= maxHealth");
        damageCalcExpr = Expression::Parse("max(0, damage - armor) * (1.0 + level * 0.1)");
        levelUpExpr = Expression::Parse("exp >= level * 100");
    }
    
    // Efficient execution in game loop
    void gameLoop() {
        for (int frame = 0; frame < 10000; ++frame) {
            // Execute every frame without re-parsing
            bool playerAlive = healthCheckExpr->evaluate(&environment).asBoolean();
            
            if (playerAlive) {
                // Calculate damage (assuming damage and armor are set)
                double finalDamage = damageCalcExpr->evaluate(&environment).asNumber();
                
                // Check level up
                bool canLevelUp = levelUpExpr->evaluate(&environment).asBoolean();
                
                // Game logic...
            }
        }
    }
};
```

## 📄 License

This project is licensed under the MIT License – see the license notice in the file headers.

## 🔧 Supported Syntax (Both C++ and Swift)

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
| 5 | `<`, `>`, `<=`, `>=` | Relational comparison | `age >= 18`, `score < 100` |
| 6 | `==`, `!=` | Equality comparison | `name == "admin"`, `id != 0` |
| 7 | `xor` | Logical XOR | `a xor b` |
| 8 | `&&`, `and` | Logical AND | `a && b`, `x and y` |
| 9 | `\|\|`, `or` | Logical OR | `a \|\| b`, `x or y` |

### Variables and Functions
- **Variables**: `x`, `health`, `pos.x`, `player_name`
- **Function calls**: `max(a, b)`, `sqrt(x)`, `distance(x1, y1, x2, y2)`

### Built-in Mathematical Functions
ExpressionKit provides a comprehensive set of standard mathematical functions through the `CallStandardFunctions` method:

| Function | Description | Example |
|----------|-------------|---------|
| `min(a, b)` | Returns the smaller of two numbers | `min(10, 5)` → `5` |
| `max(a, b)` | Returns the larger of two numbers | `max(10, 5)` → `10` |
| `sqrt(x)` | Returns the square root of x | `sqrt(16)` → `4` |
| `sin(x)` | Returns the sine of x (radians) | `sin(3.14159/2)` → `1` |
| `cos(x)` | Returns the cosine of x (radians) | `cos(0)` → `1` |
| `tan(x)` | Returns the tangent of x (radians) | `tan(0)` → `0` |
| `abs(x)` | Returns the absolute value of x | `abs(-5)` → `5` |
| `pow(x, y)` | Returns x raised to the power of y | `pow(2, 3)` → `8` |
| `log(x)` | Returns the natural logarithm of x | `log(2.718)` → `≈1` |
| `exp(x)` | Returns e raised to the power of x | `exp(1)` → `≈2.718` |
| `floor(x)` | Returns the largest integer ≤ x | `floor(3.7)` → `3` |
| `ceil(x)` | Returns the smallest integer ≥ x | `ceil(3.2)` → `4` |
| `round(x)` | Returns x rounded to nearest integer | `round(3.6)` → `4` |

These functions can be used in IEnvironment implementations to provide mathematical capabilities:

```cpp
class MathEnvironment : public ExpressionKit::IEnvironment {
public:
    ExpressionKit::Value Call(const std::string& name, 
                             const std::vector<ExpressionKit::Value>& args) override {
        ExpressionKit::Value result;
        
        // Try standard mathematical functions first
        if (Expression::CallStandardFunctions(name, args, result)) {
            return result;
        }
        
        // Custom functions...
        throw ExpressionKit::ExprException("Unknown function: " + name);
    }
    
    // ... other methods
};
```
## 🏗️ Architecture Design

### Core Components

1. **Value** - Unified value type supporting numbers, booleans, and strings
2. **IEnvironment** - Interface for variable and function access
3. **ASTNode** - Base protocol for abstract syntax tree nodes
4. **Parser** - Recursive descent parser
5. **Expression** - Main expression utility class
6. **CompiledExpression** - Pre-parsed AST for efficient repeated evaluation

### Swift Pure Implementation Architecture

ExpressionKit uses a **pure Swift implementation** that directly translates the C++ algorithms:

1. **ExpressionKit.hpp** - Reference C++ header-only library
2. **ExpressionKit.swift** - Pure Swift 1:1 translation of the C++ implementation
3. **Native Swift Implementation** - Complete reimplementation using Swift-idiomatic patterns

```
Swift Code
    ↓
ExpressionKit.swift (Pure Swift Implementation)
    ↓
Native Swift AST & Parser (Translated from C++)
```

### Benefits of Pure Swift Architecture

- **Performance**: No bridge overhead, native Swift execution
- **Maintainability**: Single codebase easier to maintain and debug
- **Platform Support**: Works on all Swift platforms without C++ dependencies
- **Memory Management**: Native Swift ARC instead of manual C++ memory management
- **Debugging**: Full Swift debugging capabilities and stack traces
- **Distribution**: Simpler package distribution without mixed-language complexity

### Design Principles

The pure Swift implementation maintains the same design principles as the C++ version:
- **Type Safety**: Strong typing with automatic conversions where appropriate
- **Performance**: "Parse once, execute many" pattern for optimal performance
- **Extensibility**: Clean environment interface for custom variables and functions
- **Reliability**: Comprehensive error handling and validation

### IEnvironment Interface

The IEnvironment is a core design pattern in ExpressionKit, providing:

```swift
public protocol IEnvironment: AnyObject {
    /// Get a variable value by name
    func get(_ name: String) throws -> Value
    
    /// Call a function with given arguments  
    func call(_ name: String, args: [Value]) throws -> Value
}
```

**Example Implementation:**
```swift
class GameEnvironment: IEnvironment {
    private var variables: [String: Value] = [:]
    
    init() {
        // Initialize game state
        variables["health"] = Value(100.0)
        variables["maxHealth"] = Value(100.0) 
        variables["level"] = Value(5.0)
        variables["isAlive"] = Value(true)
        variables["pos.x"] = Value(10.5)
        variables["pos.y"] = Value(20.3)
    }
    
    func get(_ name: String) throws -> Value {
        guard let value = variables[name] else {
            throw ExpressionError.unknownVariable(name)
        }
        return value
    }
    
    func call(_ name: String, args: [Value]) throws -> Value {
        // Try standard mathematical functions first
        if let result = try callStandardFunctions(name, args: args) {
            return result
        }
        
        // Custom functions
        if name == "distance" && args.count == 4 {
            let x1 = try args[0].asNumber(), y1 = try args[1].asNumber()
            let x2 = try args[2].asNumber(), y2 = try args[3].asNumber()
            let dx = x2 - x1, dy = y2 - y1
            return Value(sqrt(dx*dx + dy*dy))
        }
        throw ExpressionError.unknownFunction(name)
    }
}
```

Advantages of this design:
- **Decoupling**: Separates expression parsing from concrete data sources
- **Flexibility**: Can integrate with any data source (database, config files, game state, etc.)
- **Testability**: Easy to create mock IEnvironments for different scenarios
- **Performance**: Direct method calls, no reflection or string lookups

## 📊 Performance Characteristics

### Benefits of Pre-Parsed AST

1. **Parse once, execute many times**
   ```swift
   // Slow: parse every time
   for i in 0..<1000000 {
       let result = try Expression.eval("complex_expression", environment: environment)
   }
   
   // Fast: pre-parse and reuse
   let compiled = try Expression.parse("complex_expression")
   for i in 0..<1000000 {
       let result = try compiled.evaluate(environment)
   }
   ```

2. **Memory efficiency**: Swift ARC manages memory automatically and efficiently
3. **Type safety**: Swift's strong type system with runtime validation
4. **Native performance**: No bridge overhead, pure Swift execution

## 🎯 Use Cases

- **Game engines**: Skill systems, AI condition checks, configuration expressions
- **Configuration systems**: Dynamic rules, conditional logic
- **Business rule engines**: Complex business logic expressions
- **Data processing**: Computed fields, filtering conditions
- **Scripting systems**: Embedded expression evaluation

## 🔍 Error Handling

ExpressionKit uses Swift's error handling system:

```swift
do {
    let result = try Expression.eval("invalid expression ++ --", environment: environment)
} catch let error as ExpressionError {
    print("Expression error: \(error.localizedDescription)")
} catch {
    print("Unexpected error: \(error)")
}
```

Common error types:
- **Parse errors**: Invalid expression syntax (`ExpressionError.parseError`)
- **Type errors**: Mismatched operand types (`ExpressionError.typeError`)
- **Runtime errors**: Division by zero (`ExpressionError.divisionByZero`)
- **Variable errors**: Unknown variables (`ExpressionError.unknownVariable`)
- **Function errors**: Unknown functions (`ExpressionError.unknownFunction`)
- **Domain errors**: Mathematical domain violations (`ExpressionError.domainError`)

## 🚧 Requirements

### Swift Implementation
- **Swift 5.7** or later
- **Platforms**: macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+
- **Dependencies**: None (pure Swift)

### C++ Implementation  
- **C++11** or later
- **Dependencies**: Only C++ standard library

## 📚 More Examples

### Running Live Demos

For comprehensive interactive examples, see our **[Demo & Test Targets section](#-try-it-live---demo--test-targets)** above, which includes:

- **ExpressionDemo**: Interactive CLI with syntax highlighting
- **TokenDemo**: Token sequence analysis demonstration  
- **ExprTKTest**: Complete unit test suite
- **Swift Example**: Full Swift API showcase

### Code Examples

See the dedicated demo files for complete working examples:

- **`CPP/demo.cpp`**: Interactive CLI demo with full ExpressionKit features
- **`CPP/token_demo.cpp`**: Advanced token sequence collection and analysis  
- **`CPP/test.cpp`**: Comprehensive unit tests and usage examples
- **`Swift/Examples/SwiftExample/`**: Complete Swift API demonstration

See the files above for additional usage examples and test cases.

## 🤝 Contributing

As this project is primarily AI-generated, for suggested changes:
1. Provide specific feature requirements
2. Describe the desired API design
3. Include test cases

## 📞 Support

For questions or suggestions, please open an Issue or review the code comments for implementation details.
