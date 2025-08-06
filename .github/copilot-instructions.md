# Copilot Instructions for ExpressionKit

## Project Architecture

ExpressionKit follows **1:1 translation philosophy** across languages:
- **C++ core**: `ExpressionKit.hpp` (1140 lines) - reference implementation  
- **Swift**: `Swift/Sources/ExpressionKit/ExpressionKit.swift` (1408 lines)
- **Future targets**: C#, Java, Kotlin, TypeScript where direct C++ integration is impractical
- **Principle**: Identical AST structure, algorithms, and behavior across all implementations

## Core Components

- `Value`: Type-safe union (NUMBER/BOOLEAN/STRING) with conversions
- `IEnvironment`/`EnvironmentProtocol`: Variable/function resolution interface
- AST nodes: `NumberNode`, `BooleanNode`, `StringNode`, `VariableNode`, `BinaryOpNode`, `UnaryOpNode`, `FunctionCallNode`
- `Expression`: Main API with `Eval()` (direct) and `parse()`+`evaluate()` (compiled)

### Environment Pattern
```cpp
// C++ - Implement IEnvironment
class MyEnv : public IEnvironment {
    Value Get(const std::string& name) override { /* variables */ }
    Value Call(const std::string& name, const std::vector<Value>& args) override { /* functions */ }
};
```

**Other languages**: Follow official language guidelines and idiomatic patterns:
- Swift: Use protocols and class-based implementations per Swift conventions
- C#: Follow .NET interface patterns and naming conventions  
- Java: Use standard interface implementation patterns
- Kotlin: Follow Kotlin interface and class conventions with proper null safety
- TypeScript: Use interface-based patterns with proper typing

## Build & Test Commands

### C++ Development
```bash
cd CPP && cmake . && make
make ExprTKTest && ./ExprTKTest          # 28 cases, 332 assertions
make ExpressionDemo && ./ExpressionDemo # Interactive CLI
make TokenDemo && ./TokenDemo           # Token analysis
```

### Swift Development
```bash
swift test                               # 60 test methods
cd Swift/Examples/SwiftExample && swift run
```

### Cross-Language Testing
```bash
./scripts/run_all_tests.sh              # Both C++ and Swift
./scripts/run_cpp_tests.sh              # C++ only (Catch2)
./scripts/run_swift_tests.sh            # Swift only (XCTest)
```

## Development Rules

### 1:1 Translation Requirements
- Maintain identical algorithms, AST structure, operator precedence
- Each C++ test case needs equivalent in all target languages
- Use language idioms but preserve core behavior
- Handle errors consistently (C++: `ExprException`, Swift: `ExpressionError` enum)

### Token Collection
```cpp
std::vector<Token> tokens;
auto result = Expression::Eval("2 + sqrt(x)", env, &tokens);
```

```swift
let (result, tokens) = try Expression.eval("2 + sqrt(x)", environment: env, collectTokens: true)
```

## Testing Requirements

**All implementations must pass equivalent tests before any commit.**

- C++: `TestEnvironment` with `std::map<std::string, Value>`
- Swift: `SimpleEnvironment` with dictionary backing
- Test scenarios: arithmetic, boolean logic, variables, functions, errors, edge cases
- Pre-commit: Run `./scripts/run_all_tests.sh` - must show all PASSED

## Adding Features

1. Implement in C++ `ExpressionKit.hpp` first
2. Add C++ tests in `CPP/test.cpp`
3. Translate to target languages maintaining 1:1 algorithms
4. Add equivalent tests in each language
5. Verify all tests pass: `./scripts/run_all_tests.sh`

## Project Structure
- **Dependencies**: None (header-only C++, pure language implementations)
- **Build systems**: CMake (C++), Swift Package Manager, future NuGet/Maven/Gradle/npm
- **Architecture**: Single header C++, clean language-specific APIs
