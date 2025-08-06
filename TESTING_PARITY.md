# Testing Parity Principle

This document establishes the testing parity principle for ExpressionKit, ensuring that both C++ and Swift implementations receive equivalent comprehensive test coverage.

## Core Principle

**Both C++ and Swift implementations must maintain equivalent test coverage to ensure behavioral consistency and feature parity.**

## Current Test Coverage Status

### C++ Tests (28 test cases, 332 assertions)
- ✅ **Complete coverage** of all core features:
  - Variables with TestEnvironment (complex scenarios)
  - Custom function calls (`add` function)
  - Standard mathematical functions (min, max, pow, sqrt, abs, floor, ceil, round, sin, cos, tan, exp, log)
  - String operations (concatenation, comparison, "in" operator)
  - Real-world scenarios (geometry, game logic, business rules)
  - Complex boolean logic with variables
  - Token collection for syntax highlighting
  - String literals with escape sequences
  - Type conversions and edge cases
  - Error handling

### Swift Tests (60 test methods)
- ✅ **Core arithmetic and boolean logic** (comprehensive)
- ✅ **Variables with SimpleEnvironment** (basic to complex)
- ✅ **Standard mathematical functions** (complete parity with C++)
- ✅ **Real-world scenarios** (geometry, business logic)
- ✅ **Ternary operator** (unique to Swift, not in C++)
- ✅ **Error handling and API patterns**
- ✅ **Token collection**
- ✅ **String literals and operations**
- ⚠️ **String "in" operator** (implemented but behavior differs from C++)
- ✅ **Performance testing patterns**

## Key Differences Identified

### 1. String "in" Operator Behavior
- **C++**: `"" in "hello world"` → `true` (empty string contained in any string)
- **Swift**: `"" in "hello world"` → `false` (different behavior)
- **Status**: Known limitation documented in Swift tests

### 2. Test Organization
- **C++**: Section-based with comprehensive scenarios in single test cases
- **Swift**: Method-based with more granular, focused tests
- **Result**: Swift has more test methods (60) but C++ has more assertions per test (332 total)

### 3. Feature Coverage
- **C++ Missing**: Ternary operator tests (though implementation exists)
- **Swift Missing**: Nothing significant - comprehensive coverage achieved

## Testing Standards

### 1. Feature Parity Requirements
Every feature supported in one implementation must have equivalent tests in the other:

- **Variables and Environment**: Both implementations must test variable access, complex expressions with variables, and environment patterns
- **Mathematical Functions**: All standard functions (min, max, pow, sqrt, abs, floor, ceil, round, sin, cos, tan, exp, log) must be tested
- **String Operations**: Concatenation, comparison, and containment operations
- **Real-World Scenarios**: Complex business logic, geometry calculations, and multi-variable expressions
- **Error Handling**: Both implementations must test equivalent error conditions
- **Token Collection**: Syntax highlighting support must be verified in both

### 2. Test Coverage Metrics
- **C++**: Aim for comprehensive scenarios with multiple assertions per test case
- **Swift**: Maintain granular test methods with focused assertions
- **Both**: Must cover edge cases, error conditions, and performance patterns

### 3. Behavioral Consistency
When implementations differ (like the string "in" operator), differences must be:
1. **Documented** in test comments
2. **Tracked** as known limitations
3. **Evaluated** for future alignment

## Implementation Guidelines

### Adding New Features
1. **Design Phase**: Consider both C++ and Swift implementation requirements
2. **Implementation Phase**: Implement in both languages with consistent behavior
3. **Testing Phase**: Create equivalent test coverage in both test suites
4. **Documentation Phase**: Update this document with any behavioral differences

### Maintaining Parity
1. **Regular Audits**: Review test coverage between implementations
2. **Feature Gaps**: Address missing tests when identified
3. **Behavioral Differences**: Document and track for resolution
4. **Test Count Balance**: While test method counts may differ, assertion coverage should be equivalent

## Current Status Summary

✅ **Swift test coverage enhanced** with essential C++ parity features:
- Variables and Environment testing
- Standard mathematical functions (complete)
- Real-world complex scenarios
- String operations (partial - "in" operator differs)

✅ **Both implementations** now have comprehensive test coverage

⚠️ **Known limitation**: String "in" operator behavior differs between implementations

📋 **Future work**: Consider fixing string "in" operator behavior in Swift or documenting as intentional difference

---

*This document should be updated whenever new features are added or test coverage is modified to maintain the testing parity principle.*