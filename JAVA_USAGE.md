# ExpressionKit Java Usage Guide

ExpressionKit provides a clean and powerful Java API for parsing and evaluating mathematical and logical expressions. This guide shows how to use the Java implementation.

## 🚀 Quick Start

### Basic Expression Evaluation

```java
import com.expressionkit.*;

public class Example {
    public static void main(String[] args) throws ExpressionException {
        // Simple arithmetic
        Value result = Expression.eval("2 + 3 * 4"); 
        System.out.println(result.asNumber()); // 14.0

        // Boolean expressions
        Value boolResult = Expression.eval("true && (5 > 3)");
        System.out.println(boolResult.asBoolean()); // true

        // String expressions
        Value stringResult = Expression.eval("\"Hello\" + \" World\"");
        System.out.println(stringResult.asString()); // "Hello World"
    }
}
```

### Using Variables and Functions

```java
import com.expressionkit.*;

public class VariableExample {
    public static void main(String[] args) throws ExpressionException {
        // Create environment for variables
        SimpleEnvironment env = new SimpleEnvironment();
        env.set("x", 10.0);
        env.set("y", 5.0);
        env.set("name", "ExpressionKit");

        // Evaluate with variables
        Value result1 = Expression.eval("x + y * 2", env); // 20.0
        Value result2 = Expression.eval("sqrt(x * x + y * y)", env); // 11.18...
        Value result3 = Expression.eval("name + \" rocks!\"", env); // "ExpressionKit rocks!"

        System.out.println("x + y * 2 = " + result1.asNumber());
        System.out.println("Distance = " + result2.asNumber());
        System.out.println("Message = " + result3.asString());
    }
}
```

### High-Performance Compiled Expressions

For expressions that need to be evaluated multiple times, compile them once for better performance:

```java
import com.expressionkit.*;

public class CompiledExample {
    public static void main(String[] args) throws ExpressionException {
        SimpleEnvironment env = new SimpleEnvironment();
        
        // Compile once
        Expression.CompiledExpression compiled = Expression.compile("x * x + y * y");
        
        // Execute many times efficiently
        for (int i = 1; i <= 10; i++) {
            env.set("x", i);
            env.set("y", i * 2);
            
            Value result = compiled.evaluate(env);
            System.out.printf("x=%d, y=%d: result=%.2f%n", 
                            i, i*2, result.asNumber());
        }
    }
}
```

### Token Analysis for Syntax Highlighting

```java
import com.expressionkit.*;
import java.util.List;

public class TokenExample {
    public static void main(String[] args) throws ExpressionException {
        String expression = "max(x, sqrt(y)) + 5";
        
        // Evaluate and collect tokens
        Expression.EvalResult result = Expression.evalWithTokens(expression, null);
        
        System.out.println("Expression: " + expression);
        System.out.println("Result: " + result.getValue());
        System.out.println("Tokens:");
        
        List<Token> tokens = result.getTokens();
        for (Token token : tokens) {
            System.out.printf("  %s: '%s' at %d:%d%n",
                            token.getType(), 
                            token.getText(),
                            token.getStart(),
                            token.getLength());
        }
    }
}
```

## 📚 API Reference

### Core Classes

#### `Expression`
Main utility class for expression evaluation and parsing.

**Static Methods:**
- `eval(String expression)` - Evaluate expression without variables
- `eval(String expression, IEnvironment env)` - Evaluate with environment
- `compile(String expression)` - Compile expression for repeated use
- `parse(String expression)` - Parse into AST
- `evalWithTokens(String expression, IEnvironment env)` - Evaluate with token collection

#### `Value`
Type-safe value container supporting numbers, booleans, and strings.

**Constructors:**
- `Value(double number)`
- `Value(boolean value)`
- `Value(String text)`

**Methods:**
- `isNumber()`, `isBoolean()`, `isString()` - Type checking
- `asNumber()`, `asBoolean()`, `asString()` - Type conversion with validation

#### `SimpleEnvironment`
Basic implementation of `IEnvironment` for variable storage.

**Methods:**
- `set(String name, Value value)` - Set variable
- `set(String name, double value)` - Set numeric variable (convenience)
- `set(String name, boolean value)` - Set boolean variable (convenience)
- `set(String name, String value)` - Set string variable (convenience)
- `remove(String name)` - Remove variable
- `contains(String name)` - Check if variable exists
- `clear()` - Remove all variables

### Custom Environments

Implement `IEnvironment` for custom variable and function handling:

```java
class GameEnvironment implements IEnvironment {
    private Map<String, Value> variables = new HashMap<>();
    
    public GameEnvironment() {
        variables.put("health", new Value(100.0));
        variables.put("maxHealth", new Value(100.0));
        variables.put("level", new Value(5.0));
    }
    
    @Override
    public Value get(String name) throws ExpressionException {
        Value value = variables.get(name);
        if (value == null) {
            throw new ExpressionException.UnknownVariableException(name);
        }
        return value;
    }
    
    @Override
    public Value call(String name, List<Value> args) throws ExpressionException {
        // Try standard functions first
        Value result = StandardFunctions.call(name, args);
        if (result != null) return result;
        
        // Custom functions
        if ("damage".equals(name) && args.size() == 2) {
            double baseDamage = args.get(0).asNumber();
            double level = args.get(1).asNumber();
            return new Value(baseDamage * (1.0 + level * 0.1));
        }
        
        throw new ExpressionException.UnknownFunctionException(name);
    }
}
```

## 🎯 Supported Syntax

### Data Types
- **Numbers**: `42`, `3.14`, `-2.5`
- **Booleans**: `true`, `false`  
- **Strings**: `"hello"`, `"world"`, `"escaped \"quotes\""`

### Operators (by precedence)
1. `()` - Grouping
2. `!`, `not`, `-` (unary) - Unary operators
3. `*`, `/` - Multiplication/Division
4. `+`, `-` - Addition/Subtraction
5. `<`, `>`, `<=`, `>=`, `in` - Relational operators
6. `==`, `!=` - Equality operators
7. `xor` - Logical XOR
8. `&&`, `and` - Logical AND
9. `||`, `or` - Logical OR
10. `?:` - Ternary conditional

### Built-in Functions
- **Math**: `min`, `max`, `sqrt`, `pow`, `abs`
- **Trigonometric**: `sin`, `cos`, `tan`
- **Logarithmic**: `log`, `exp`
- **Rounding**: `floor`, `ceil`, `round`

### Examples

```java
// Arithmetic
Expression.eval("2 + 3 * 4")              // 14.0

// Boolean logic  
Expression.eval("true && (5 > 3)")        // true
Expression.eval("false || true")          // true
Expression.eval("true xor false")         // true

// String operations
Expression.eval("\"Hello\" + \" World\"")   // "Hello World"
Expression.eval("\"abc\" < \"def\"")        // true
Expression.eval("\"ll\" in \"hello\"")      // true

// Mathematical functions
Expression.eval("max(10, 5)")            // 10.0
Expression.eval("sqrt(16)")              // 4.0
Expression.eval("pow(2, 3)")             // 8.0

// Ternary operator
Expression.eval("5 > 3 ? \"yes\" : \"no\"")  // "yes"

// Complex expressions
Expression.eval("sqrt(3*3 + 4*4) == 5")  // true
```

## 🛠️ Build Setup

### Gradle

Add to your `build.gradle`:

```gradle
dependencies {
    implementation files('path/to/expressionkit.jar')
    // Or if published to a repository:
    // implementation 'com.expressionkit:expressionkit:1.0.0'
}
```

### Maven

Add to your `pom.xml`:

```xml
<dependency>
    <groupId>com.expressionkit</groupId>
    <artifactId>expressionkit</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 🎮 Demo Applications

The Java implementation includes interactive demo applications:

### Expression Demo
```bash
cd Java
./gradlew demo
```

Interactive CLI with:
- Expression evaluation
- Variable management  
- Token analysis
- Syntax highlighting

### Token Demo
```bash  
cd Java
./gradlew tokenDemo
```

Demonstrates token collection for syntax highlighting and analysis.

## 🧪 Running Tests

```bash
cd Java
./gradlew test
```

The test suite includes 35+ comprehensive tests covering:
- Basic expression evaluation
- All operators and precedence rules
- Variable and function support
- Error handling
- Type conversions
- Token collection
- Performance testing

## 🚀 Performance Tips

1. **Use compiled expressions** for repeated evaluation:
   ```java
   Expression.CompiledExpression compiled = Expression.compile("complex_expression");
   // Reuse compiled many times
   ```

2. **Reuse environments** when possible:
   ```java
   SimpleEnvironment env = new SimpleEnvironment();
   // Set up variables once, use for multiple evaluations
   ```

3. **Avoid token collection** in performance-critical code unless needed for analysis.

## ❌ Error Handling

ExpressionKit uses typed exceptions for different error conditions:

```java
try {
    Value result = Expression.eval("invalid + + syntax");
} catch (ExpressionException.ParseException e) {
    System.err.println("Parse error: " + e.getMessage());
} catch (ExpressionException.UnknownVariableException e) {
    System.err.println("Unknown variable: " + e.getMessage());
} catch (ExpressionException.DivisionByZeroException e) {
    System.err.println("Division by zero!");
} catch (ExpressionException e) {
    System.err.println("Expression error: " + e.getMessage());
}
```

## 🔗 Integration Examples

### Game Development
```java
class GameLogic {
    private SimpleEnvironment gameState = new SimpleEnvironment();
    private Expression.CompiledExpression healthCheck;
    private Expression.CompiledExpression damageCalc;
    
    public GameLogic() {
        healthCheck = Expression.compile("health > 0 && health <= maxHealth");
        damageCalc = Expression.compile("baseDamage * (1 + level * 0.1)");
    }
    
    public boolean isPlayerAlive() throws ExpressionException {
        return healthCheck.evaluate(gameState).asBoolean();
    }
    
    public double calculateDamage() throws ExpressionException {
        return damageCalc.evaluate(gameState).asNumber();
    }
}
```

### Configuration System
```java
class ConfigSystem {
    private SimpleEnvironment config = new SimpleEnvironment();
    
    public void loadConfig() {
        config.set("maxConnections", 100);
        config.set("timeoutMs", 5000);
        config.set("enableLogging", true);
    }
    
    public boolean shouldAllow(String rule) throws ExpressionException {
        return Expression.eval(rule, config).asBoolean();
    }
}
```

For more examples, see the demo applications in the `examples` package.