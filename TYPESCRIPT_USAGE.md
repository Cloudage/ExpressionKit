# ExpressionKit TypeScript Usage Guide

A lightweight, interface-driven expression parser and evaluator for TypeScript, translated 1:1 from the C++ ExpressionKit implementation.

## 🚀 Quick Start

### Installation

**Option 1: One-line installer (Recommended - Like Swift Package Manager)**
```bash
curl -sSL https://raw.githubusercontent.com/Cloudage/ExpressionKit/main/scripts/install-typescript.sh | bash
```

**Option 2: Manual GitHub clone**
```bash
git clone https://github.com/Cloudage/ExpressionKit.git
cd ExpressionKit/TypeScript
npm install && npm run build
# Copy dist files to your project
```

**Option 3: From npm registry (when published)**
```bash
npm install expressionkit-typescript
```

### Basic Usage

```typescript
import { Expression, SimpleEnvironment, Value } from 'expressionkit-typescript';

// Simple arithmetic
const result = Expression.evalSimple('2 + 3 * 4'); // 14
console.log(result.asNumber()); // 14

// Boolean expressions
const boolResult = Expression.evalSimple('true && (5 > 3)');
console.log(boolResult.asBoolean()); // true

// String literals
const stringResult = Expression.evalSimple('"Hello, World!"');
console.log(stringResult.asString()); // Hello, World!
```

## 🏗️ Core Architecture

ExpressionKit TypeScript follows the same 1:1 translation approach as the Swift implementation:

- **Value**: Type-safe union (NUMBER/BOOLEAN/STRING) with conversions
- **IEnvironment**: Interface for variable/function resolution  
- **Expression**: Main API with `evalSimple()` and `parse()+evaluate()` methods
- **Token system**: For syntax highlighting capabilities
- **Built-in functions**: All mathematical functions from C++ reference

## 📊 Value System

The `Value` class provides type-safe handling of numbers, booleans, and strings:

```typescript
import { Value, ValueType } from 'expressionkit-typescript';

// Create values
const num = new Value(42);
const bool = new Value(true);
const str = new Value("hello");

// Type checking
console.log(num.type === ValueType.NUMBER); // true
console.log(bool.type === ValueType.BOOLEAN); // true
console.log(str.type === ValueType.STRING); // true

// Automatic conversions
console.log(num.asNumber()); // 42
console.log(num.asBoolean()); // true (non-zero)
console.log(num.asString()); // "42"

console.log(bool.asNumber()); // 1.0
console.log(bool.asBoolean()); // true
console.log(bool.asString()); // "true"
```

## 🎯 Environment Pattern

Use `IEnvironment` for variable and function resolution:

### SimpleEnvironment

```typescript
import { SimpleEnvironment, Value, Expression } from 'expressionkit-typescript';

const env = new SimpleEnvironment();

// Set variables
env.setVariable('health', new Value(75));
env.setVariable('maxHealth', new Value(100));
env.setVariable('pos.x', new Value(10.5)); // Dot notation supported

// Use in expressions
const healthPercent = Expression.evalSimple('health / maxHealth * 100', env);
console.log(healthPercent.asNumber()); // 75

const lowHealth = Expression.evalSimple('health < maxHealth * 0.5', env);
console.log(lowHealth.asBoolean()); // false

const position = Expression.evalSimple('pos.x', env);
console.log(position.asNumber()); // 10.5
```

### Custom Environment

```typescript
import { IEnvironment, Value, ExpressionError } from 'expressionkit-typescript';

class GameEnvironment implements IEnvironment {
    private variables = new Map<string, Value>();
    
    constructor() {
        this.variables.set('health', new Value(100));
        this.variables.set('level', new Value(5));
    }
    
    get(name: string): Value {
        const value = this.variables.get(name);
        if (value === undefined) {
            throw ExpressionError.unknownVariable(name);
        }
        return value;
    }
    
    call(name: string, args: Value[]): Value {
        // Standard mathematical functions are handled automatically
        
        // Custom functions
        if (name === 'distance' && args.length === 4) {
            const x1 = args[0].asNumber(), y1 = args[1].asNumber();
            const x2 = args[2].asNumber(), y2 = args[3].asNumber();
            const dx = x2 - x1, dy = y2 - y1;
            return new Value(Math.sqrt(dx*dx + dy*dy));
        }
        
        throw ExpressionError.unknownFunction(name);
    }
}

const gameEnv = new GameEnvironment();
const distance = Expression.evalSimple('distance(0, 0, 3, 4)', gameEnv);
console.log(distance.asNumber()); // 5.0
```

## ⚡ Pre-compiled Expressions

Parse once, execute many times for optimal performance:

```typescript
import { Expression } from 'expressionkit-typescript';

const env = new SimpleEnvironment();
const compiled = Expression.parse('(health / maxHealth) * 100');

// Execute multiple times with different variable values
env.setVariable('health', new Value(75));
env.setVariable('maxHealth', new Value(100));
console.log(compiled.evaluate(env).asNumber()); // 75

env.setVariable('health', new Value(90));
console.log(compiled.evaluate(env).asNumber()); // 90
```

## 🧮 Built-in Mathematical Functions

All standard mathematical functions are supported:

```typescript
// Two-argument functions
Expression.evalSimple('min(5, 10)').asNumber()  // 5
Expression.evalSimple('max(5, 10)').asNumber()  // 10
Expression.evalSimple('pow(2, 3)').asNumber()   // 8

// Single-argument functions
Expression.evalSimple('sqrt(16)').asNumber()    // 4
Expression.evalSimple('abs(-5)').asNumber()     // 5
Expression.evalSimple('floor(3.7)').asNumber()  // 3
Expression.evalSimple('ceil(3.2)').asNumber()   // 4
Expression.evalSimple('round(3.6)').asNumber()  // 4

// Trigonometric functions
Expression.evalSimple('sin(0)').asNumber()      // 0
Expression.evalSimple('cos(0)').asNumber()      // 1
Expression.evalSimple('tan(0)').asNumber()      // 0

// Logarithmic functions  
Expression.evalSimple('log(1)').asNumber()      // 0
Expression.evalSimple('exp(0)').asNumber()      // 1
```

## 🎨 Token Collection for Syntax Highlighting

Collect tokens during parsing for syntax highlighting and analysis:

```typescript
import { Expression, TokenType } from 'expressionkit-typescript';

const [result, tokens] = Expression.eval('max(x + 5, y * 2)', env, true);
console.log(result.asNumber()); // Expression result

if (tokens) {
    tokens.forEach(token => {
        console.log(`${TokenType[token.type]}: "${token.text}" at ${token.start}:${token.length}`);
    });
}

// Output:
// IDENTIFIER: "max" at 0:3
// PARENTHESIS: "(" at 3:1
// IDENTIFIER: "x" at 4:1
// OPERATOR: "+" at 6:1
// NUMBER: "5" at 8:1
// COMMA: "," at 9:1
// IDENTIFIER: "y" at 11:1
// OPERATOR: "*" at 13:1
// NUMBER: "2" at 15:1
// PARENTHESIS: ")" at 16:1
```

Token types available:
- `NUMBER`: Numeric literals
- `BOOLEAN`: Boolean literals
- `STRING`: String literals  
- `IDENTIFIER`: Variables and function names
- `OPERATOR`: All operators
- `PARENTHESIS`: Grouping symbols
- `COMMA`: Function argument separator
- `WHITESPACE`: Spaces and tabs

## 🔧 Supported Syntax

### Data Types
- **Numbers**: `42`, `3.14`, `-2.5`
- **Booleans**: `true`, `false` 
- **Strings**: `"hello"`, `"world"`, `""`

### Operators (by precedence)

| Precedence | Operator | Description | Example |
|------------|----------|-------------|---------|
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

## ❌ Error Handling

ExpressionKit uses TypeScript's error handling:

```typescript
import { ExpressionError } from 'expressionkit-typescript';

try {
    const result = Expression.evalSimple('1 / 0');
} catch (error) {
    if (error instanceof ExpressionError) {
        console.log('Expression error:', error.message);
        console.log('Error cause:', error.cause);
    }
}
```

Common error types:
- **Parse errors**: Invalid expression syntax
- **Type errors**: Mismatched operand types
- **Runtime errors**: Division by zero
- **Variable errors**: Unknown variables
- **Function errors**: Unknown functions
- **Domain errors**: Mathematical domain violations

## 📈 Performance Characteristics

### Benefits of Pre-Parsed AST

```typescript
// Slow: parse every time
for (let i = 0; i < 1000000; i++) {
    const result = Expression.evalSimple('complex_expression', environment);
}

// Fast: pre-parse and reuse  
const compiled = Expression.parse('complex_expression');
for (let i = 0; i < 1000000; i++) {
    const result = compiled.evaluate(environment);
}
```

### Token Collection Overhead

Token collection has minimal performance overhead (~10%), so collect tokens only when needed for syntax highlighting or analysis.

## 🔄 Cross-Language Compatibility

The TypeScript implementation maintains **100% behavioral compatibility** with the C++ and Swift versions:

- **Identical algorithms**: Same parsing logic, operator precedence, evaluation rules
- **Same test coverage**: All test cases translated from C++ test suite
- **Equivalent APIs**: While using TypeScript idioms, functionality remains identical  
- **Token compatibility**: Same token types and collection behavior

This ensures expressions evaluate identically across all supported languages.

## 🎮 Example Applications

### Game Configuration
```typescript
const gameConfig = new SimpleEnvironment();
gameConfig.setVariable('playerLevel', new Value(25));
gameConfig.setVariable('difficulty', new Value(1.5));

const damage = Expression.evalSimple('baseDamage * difficulty * (1 + playerLevel * 0.1)', gameConfig);
```

### Business Rules
```typescript
const businessRules = new SimpleEnvironment();
businessRules.setVariable('orderTotal', new Value(150));
businessRules.setVariable('customerType', new Value('premium'));

const discount = Expression.evalSimple('orderTotal > 100 && customerType == "premium" ? 0.15 : 0.05', businessRules);
```

### Mathematical Calculations
```typescript
// Scientific calculations
const result = Expression.evalSimple('sqrt(pow(velocity, 2) + pow(acceleration * time, 2))');

// Statistical operations  
const mean = Expression.evalSimple('(a + b + c + d) / 4', dataEnv);
const variance = Expression.evalSimple('pow(a - mean, 2) + pow(b - mean, 2)', statsEnv);
```

## 🛠️ Development Setup

### Building from Source

```bash
git clone https://github.com/Cloudage/ExpressionKit.git
cd ExpressionKit/TypeScript
npm install
npm run build
```

### Running Tests

```bash
npm test              # Run all tests
npm run test:watch    # Watch mode for development
```

### Development Scripts

```bash
npm run build         # Build TypeScript to JavaScript  
npm run clean         # Clean build artifacts
npm run dev <file>    # Run TypeScript file with ts-node
```

## 🤝 Contributing

ExpressionKit TypeScript follows the same 1:1 translation philosophy as other implementations. When contributing:

1. Maintain algorithmic equivalence with C++ reference implementation
2. All test cases must pass
3. New features should be implemented in C++ first, then translated
4. Follow TypeScript best practices while preserving behavior

## 📞 Support

- **Issues**: GitHub Issues for bug reports and feature requests
- **Documentation**: See inline code comments for implementation details
- **Examples**: Check the `examples/` directory for usage patterns

The TypeScript implementation provides the same powerful expression evaluation capabilities as the C++ and Swift versions, with full behavioral compatibility and TypeScript's excellent tooling support.