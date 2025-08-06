# Kotlin Usage Guide for ExpressionKit

ExpressionKit provides a comprehensive Kotlin implementation that maintains 1:1 behavioral compatibility with the C++ and Swift versions while following Kotlin conventions and idiomatic patterns.

## Quick Start

### Setting up Gradle Dependencies

#### Option 1: GitHub Packages (Recommended)

Add the GitHub Packages repository and dependency to your `build.gradle.kts`:

```kotlin
// build.gradle.kts
repositories {
    mavenCentral()
    maven {
        name = "GitHubPackages"
        url = uri("https://maven.pkg.github.com/Cloudage/ExpressionKit")
        credentials {
            username = project.findProperty("gpr.user") as String? ?: System.getenv("GITHUB_USERNAME")
            password = project.findProperty("gpr.key") as String? ?: System.getenv("GITHUB_TOKEN")
        }
    }
}

dependencies {
    implementation("com.expressionkit:ExpressionKit:1.0.0")
}
```

Create a `gradle.properties` file in your project root or user home directory:

```properties
gpr.user=your_github_username
gpr.key=your_github_token
```

#### Option 2: Local Installation

For development or if you don't have GitHub packages access:

```bash
git clone https://github.com/Cloudage/ExpressionKit.git
cd ExpressionKit/Kotlin
./gradlew publishToMavenLocal
```

Then add to your `build.gradle.kts`:

```kotlin
repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    implementation("com.expressionkit:ExpressionKit:1.0.0")
}
```

### Basic Usage

```kotlin
import com.expressionkit.*

// Simple arithmetic evaluation
val result = Expression.eval("2 + 3 * 4") // Returns Value.Number(14.0)
println("Result: ${result.asNumber()}") // 14.0

// Boolean logic
val isTrue = Expression.eval("5 > 3 && 2 < 10") // Returns Value.Boolean(true)
println("Is true: ${isTrue.asBoolean()}") // true

// String operations
val greeting = Expression.eval("\"Hello, \" + \"World!\"")
println("Greeting: ${greeting.asString()}") // Hello, World!
```

## Core Components

### Value System

ExpressionKit uses a type-safe `Value` sealed class that supports three types:

```kotlin
// Creating values
val number = Value.number(42.0)
val boolean = Value.boolean(true)
val text = Value.string("Hello")

// Type checking
if (value.isNumber()) {
    println("It's a number: ${value.asNumber()}")
}

// Safe conversions with automatic type coercion
val numAsString = number.asString() // "42"
val boolAsNumber = boolean.asNumber() // 1.0
val stringAsBool = Value.string("false").asBoolean() // false
```

### Environment Interface

The `IEnvironment` interface provides variable and function resolution:

```kotlin
class MyEnvironment : IEnvironment {
    private val variables = mutableMapOf<String, Value>()
    
    override fun get(name: String): Value {
        return variables[name] ?: throw ExpressionError("Variable '$name' not found")
    }
    
    override fun call(name: String, args: List<Value>): Value {
        return when (name) {
            "myFunction" -> {
                // Custom function implementation
                Value.number(args[0].asNumber() * 2)
            }
            else -> throw ExpressionError("Function '$name' not found")
        }
    }
}
```

### SimpleEnvironment Helper

For convenience, use the built-in `SimpleEnvironment`:

```kotlin
val env = SimpleEnvironment()

// Set variables
env.setVariable("x", 10.0)
env.setVariable("name", "Alice")
env.setVariable("enabled", true)

// Register custom functions
env.setFunction("double") { args ->
    if (args.size != 1) throw ExpressionError("double() requires 1 argument")
    Value.number(args[0].asNumber() * 2)
}

// Use in expressions
val result = Expression.eval("double(x) + 5", env) // 25.0
```

## Supported Syntax

### Arithmetic Operators

- `+`, `-`, `*`, `/`, `%` (modulo)
- `^`, `**` (exponentiation)
- Parentheses for grouping: `(2 + 3) * 4`

### Comparison Operators

- `==`, `!=` (equality/inequality)
- `<`, `>`, `<=`, `>=` (relational)

### Logical Operators

- `&&`, `and` (logical AND)
- `||`, `or` (logical OR)  
- `!`, `not` (logical NOT)

### Built-in Functions

Mathematical functions are available without requiring an environment:

```kotlin
Expression.eval("sqrt(16)")     // 4.0
Expression.eval("abs(-5)")      // 5.0
Expression.eval("pow(2, 3)")    // 8.0
Expression.eval("sin(0)")       // 0.0
Expression.eval("cos(0)")       // 1.0
Expression.eval("log(2.71828)") // ~1.0 (natural log)
Expression.eval("log10(100)")   // 2.0
Expression.eval("min(5, 3)")    // 3.0
Expression.eval("max(5, 3)")    // 5.0
```

### String Literals and Operations

```kotlin
Expression.eval("\"Hello\"")                    // String literal
Expression.eval("\"Hello\" + \" \" + \"World\"") // Concatenation
Expression.eval("\"Value: \" + 42")             // Mixed concatenation
Expression.eval("\"Count: \" + (2 + 3)")        // Expression in concatenation

// Escape sequences
Expression.eval("\"Hello\\nWorld\"")             // With newline
Expression.eval("\"He said \\\"Hi\\\"\"")       // With quotes
```

## Advanced Features

### Pre-compiled Expressions

For expressions evaluated repeatedly, pre-compile for better performance:

```kotlin
val env = SimpleEnvironment()
val compiled = Expression.parse("health > maxHealth * 0.5")

// Evaluate multiple times with different variable values
for (frame in 1..1000) {
    env.setVariable("health", getPlayerHealth(frame))
    env.setVariable("maxHealth", getMaxHealth(frame))
    val isHealthy = compiled.evaluate(env)
    // ... game logic
}
```

### Token Collection for Syntax Highlighting

ExpressionKit can collect tokens during parsing for syntax highlighting:

```kotlin
val (result, tokens) = Expression.eval("2 + sqrt(x)", env, collectTokens = true)

for (token in tokens) {
    when (token.type) {
        TokenType.NUMBER -> highlightNumber(token.text, token.start, token.length)
        TokenType.OPERATOR -> highlightOperator(token.text, token.start, token.length)
        TokenType.IDENTIFIER -> highlightVariable(token.text, token.start, token.length)
        TokenType.STRING -> highlightString(token.text, token.start, token.length)
        // ... other token types
    }
}
```

Available token types:
- `TokenType.NUMBER` - Numeric literals
- `TokenType.BOOLEAN` - Boolean literals (`true`, `false`)
- `TokenType.STRING` - String literals
- `TokenType.IDENTIFIER` - Variable and function names
- `TokenType.OPERATOR` - All operators
- `TokenType.PARENTHESIS` - `(` and `)`
- `TokenType.COMMA` - Function argument separator
- `TokenType.WHITESPACE` - Spaces and tabs
- `TokenType.UNKNOWN` - Unrecognized tokens

### Error Handling

ExpressionKit uses `ExpressionError` for all parsing and evaluation errors:

```kotlin
try {
    val result = Expression.eval("2 + ")
} catch (e: ExpressionError) {
    println("Expression error: ${e.message}")
}

// Common errors:
// - Syntax errors: "Missing closing parenthesis"
// - Type errors: "Cannot convert string 'abc' to number"
// - Division by zero: "Division by zero"
// - Unknown variables: "Variable 'x' not found"
// - Unknown functions: "Function 'unknownFunc' not found"
```

## Examples

### Game Statistics Calculator

```kotlin
val gameEnv = SimpleEnvironment()

// Player stats
gameEnv.setVariable("level", 15.0)
gameEnv.setVariable("baseAttack", 20.0)
gameEnv.setVariable("weaponDamage", 35.0)
gameEnv.setVariable("critChance", 0.15)

// Custom functions
gameEnv.setFunction("damage") { args ->
    val base = args[0].asNumber()
    val weapon = args[1].asNumber()
    val crit = args[2].asNumber()
    Value.number(base + weapon * (1 + crit))
}

val totalDamage = Expression.eval("damage(baseAttack, weaponDamage, critChance)", gameEnv)
val isHighLevel = Expression.eval("level >= 10", gameEnv)

println("Total damage: ${totalDamage.asNumber()}")
println("High level player: ${isHighLevel.asBoolean()}")
```

### Configuration Validator

```kotlin
val config = SimpleEnvironment()
config.setVariable("maxUsers", 1000.0)
config.setVariable("cacheSize", 256.0)
config.setVariable("debugMode", false)

val validations = listOf(
    "maxUsers > 0 && maxUsers <= 10000" to "Invalid user limit",
    "cacheSize >= 64 && cacheSize <= 1024" to "Invalid cache size",
    "!debugMode || maxUsers <= 100" to "Debug mode with too many users"
)

for ((expr, message) in validations) {
    val isValid = Expression.eval(expr, config)
    if (!isValid.asBoolean()) {
        println("Validation failed: $message")
    }
}
```

### Formula Calculator

```kotlin
val formulas = SimpleEnvironment()

// Register mathematical functions
formulas.setFunction("area_circle") { args ->
    if (args.size != 1) throw ExpressionError("area_circle requires 1 argument")
    val radius = args[0].asNumber()
    Value.number(3.14159 * radius * radius)
}

formulas.setFunction("area_rectangle") { args ->
    if (args.size != 2) throw ExpressionError("area_rectangle requires 2 arguments")
    Value.number(args[0].asNumber() * args[1].asNumber())
}

formulas.setVariable("pi", 3.14159)

// Calculate areas
val circleArea = Expression.eval("area_circle(5)", formulas)
val rectArea = Expression.eval("area_rectangle(4, 6)", formulas)
val complexArea = Expression.eval("area_circle(3) + area_rectangle(2, 4)", formulas)

println("Circle area: ${circleArea.asNumber()}")
println("Rectangle area: ${rectArea.asNumber()}")
println("Combined area: ${complexArea.asNumber()}")
```

## Testing

The Kotlin implementation includes comprehensive tests that ensure 1:1 compatibility with C++ and Swift:

```bash
# Run Kotlin tests
./scripts/run_kotlin_tests.sh

# Run all language tests
./scripts/run_all_tests.sh
```

The test suite covers:
- Basic arithmetic and operator precedence
- Boolean logic and comparisons
- String operations and concatenation
- Variable resolution and scoping
- Function calls (built-in and custom)
- Error handling and edge cases
- Token collection and analysis
- Type conversions and coercion
- Complex nested expressions

## Performance Tips

1. **Pre-compile frequently used expressions**: Use `Expression.parse()` once and `evaluate()` multiple times
2. **Reuse environments**: Create environment objects once and update variables as needed
3. **Minimize string operations**: Prefer numeric operations when possible
4. **Cache function implementations**: Avoid recreating function closures in hot paths
5. **Use built-in functions**: Mathematical functions like `sqrt()`, `sin()` are optimized

## Kotlin-Specific Features

The Kotlin implementation leverages Kotlin's strengths:

- **Sealed classes** for type-safe Value system
- **Extension functions** for mathematical operations
- **Null safety** throughout the API
- **Coroutine compatibility** for async evaluation
- **Interoperability** with Java and other JVM languages
- **Data classes** for immutable token and AST structures

## Integration with Android

ExpressionKit works seamlessly with Android projects:

```kotlin
// In your Android module's build.gradle.kts
dependencies {
    implementation("com.expressionkit:expressionkit:1.0.0")
}

// Usage in Android
class FormulaActivity : AppCompatActivity() {
    private val calculator = SimpleEnvironment()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set up calculator environment
        calculator.setVariable("screenWidth", resources.displayMetrics.widthPixels.toDouble())
        calculator.setVariable("density", resources.displayMetrics.density.toDouble())
        
        // Calculate layout dimensions
        val width = Expression.eval("screenWidth / density", calculator)
        // ... rest of implementation
    }
}
```

This comprehensive Kotlin implementation maintains full compatibility with the C++ and Swift versions while providing a modern, type-safe, and idiomatic Kotlin API.