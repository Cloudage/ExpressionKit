# ExpressionKit for C#

A lightweight, interface-driven expression parser and evaluator for C# and .NET applications. This is a complete 1:1 translation of the C++ reference implementation, maintaining identical algorithms, AST structure, and behavior while providing full .NET integration.

## 🚀 Key Features

- **🎯 1:1 C++ Translation**: Identical behavior to the reference C++ implementation
- **🔧 Interface-based Design**: Flexible variable and function access via `IEnvironment`
- **⚡ Pre-compiled Expressions**: Parse once, evaluate many times for optimal performance
- **🎨 Token Analysis**: Complete syntax highlighting and IDE integration support
- **🛡️ Type Safety**: Strong typing with automatic conversions between Number/Boolean/String
- **🚫 Zero Dependencies**: Pure .NET implementation with no external dependencies
- **✅ Comprehensive Tests**: 18 XUnit test methods covering all functionality

## 📦 Installation

ExpressionKit can be easily integrated into .NET projects using the standard .NET package management approaches:

### Option 1: NuGet Package Manager (Recommended)
```bash
dotnet add package Cloudage.ExpressionKit
```

### Option 2: PackageReference in .csproj
```xml
<PackageReference Include="Cloudage.ExpressionKit" Version="1.0.0" />
```

### Option 3: Package Manager Console (Visual Studio)
```powershell
Install-Package Cloudage.ExpressionKit
```

### Option 4: GitHub Packages (Latest Builds)
```bash
# Add GitHub Packages source (one time setup)
dotnet nuget add source https://nuget.pkg.github.com/Cloudage/index.json \
  --name github --username YOUR_GITHUB_USERNAME --password YOUR_GITHUB_TOKEN

# Install the package
dotnet add package Cloudage.ExpressionKit --source github
```

### Option 5: Local Project Reference
If you prefer to include the source directly:
1. Clone this repository
2. Add project reference: `<ProjectReference Include="path/to/CSharp/ExpressionKit/ExpressionKit.csproj" />`
3. Build with .NET 8.0 or later

**Requirements**: .NET 8.0 or later, zero external dependencies

## 🎯 Quick Start

### Basic Usage

```csharp
using ExpressionKit;

// Simple arithmetic
var result = Expression.Eval("2 + 3 * 4");
Console.WriteLine($"Result: {result.AsNumber()}"); // 14

// Boolean expressions
var boolResult = Expression.Eval("true && (5 > 3)");
Console.WriteLine($"Boolean: {boolResult.AsBoolean()}"); // True

// String operations
var stringResult = Expression.Eval("\"Hello \" + \"World\"");
Console.WriteLine($"String: {stringResult.AsString()}"); // Hello World
```

### Using Variables and Functions

```csharp
// Create environment
var environment = new SimpleEnvironment();
environment.SetVariable("x", 10.0);
environment.SetVariable("y", 5.0);
environment.SetVariable("isActive", true);

// Add custom function
environment.SetFunction("square", args => 
{
    if (args.Count != 1 || !args[0].IsNumber)
        throw new ExpressionException("square requires one numeric parameter");
    var val = args[0].AsNumber();
    return new Value(val * val);
});

// Evaluate with context
var result = Expression.Eval("square(x) + y * 2", environment);
Console.WriteLine($"Result: {result.AsNumber()}"); // 110

// Conditional expressions
var conditional = Expression.Eval("x > y ? \"Greater\" : \"Less or Equal\"", environment);
Console.WriteLine($"Comparison: {conditional.AsString()}"); // Greater
```

### Performance Optimization

```csharp
// Parse once, evaluate many times
var compiled = Expression.Parse("x * 2 + sqrt(y) - 1");

// Change variables and re-evaluate quickly
for (int i = 0; i < 1000; i++)
{
    environment.SetVariable("x", i);
    environment.SetVariable("y", i * i);
    var result = compiled.Evaluate(environment); // Very fast!
}
```

### Token Analysis (Syntax Highlighting)

```csharp
var tokens = new List<Token>();
var result = Expression.Eval("max(x, y) + sqrt(25)", environment, tokens);

Console.WriteLine($"Result: {result.AsNumber()}");
Console.WriteLine("Token Analysis:");
foreach (var token in tokens)
{
    Console.WriteLine($"  {token.Type,-12} '{token.Text}' at {token.Start}:{token.Length}");
}
```

Output:
```
Result: 15
Token Analysis:
  Identifier   'max' at 0:3
  Parenthesis  '(' at 3:1
  Identifier   'x' at 4:1
  Comma        ',' at 5:1
  Identifier   'y' at 7:1
  Parenthesis  ')' at 8:1
  Operator     '+' at 10:1
  Identifier   'sqrt' at 12:4
  Parenthesis  '(' at 16:1
  Number       '25' at 17:2
  Parenthesis  ')' at 19:1
```

## 📚 Supported Features

### Data Types
- **Numbers**: `42`, `3.14`, `-2.5` (double precision)
- **Booleans**: `true`, `false`
- **Strings**: `"hello"`, `"world"`, `"escape\"quotes"`

### Operators
- **Arithmetic**: `+`, `-`, `*`, `/`
- **Comparison**: `==`, `!=`, `<`, `>`, `<=`, `>=`
- **Logical**: `&&`, `||`, `!`, `and`, `or`, `not`, `xor`
- **String**: `+` (concatenation), `in` (contains)
- **Ternary**: `condition ? true_value : false_value`

### Built-in Functions
- **Math**: `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`
- **Rounding**: `floor`, `ceil`, `round`
- **Comparison**: `min`, `max`

### Advanced Features
- **Variables**: Access dynamic values via `IEnvironment`
- **Custom Functions**: Define application-specific functions
- **Expression Compilation**: Parse once, evaluate repeatedly
- **Token Collection**: Full syntax analysis for IDE features
- **Type Coercion**: Automatic conversions between types

## 🏗️ Architecture

### Value System
```csharp
// Values are strongly typed with automatic conversions
Value number = 42.0;           // Number
Value boolean = true;          // Boolean  
Value text = "hello";          // String

// Implicit conversions
Value result = Expression.Eval("5");
double num = result.AsNumber();     // 5.0
bool flag = result.AsBoolean();     // true (non-zero)
string str = result.AsString();     // "5"
```

### Environment Interface
```csharp
public interface IEnvironment
{
    Value Get(string name);                               // Variable access
    Value Call(string name, IReadOnlyList<Value> args);  // Function calls
}

// Simple implementation
public class SimpleEnvironment : IEnvironment
{
    private readonly Dictionary<string, Value> _variables = new();
    private readonly Dictionary<string, Func<IReadOnlyList<Value>, Value>> _functions = new();
    
    public void SetVariable(string name, Value value) => _variables[name] = value;
    public void SetFunction(string name, Func<IReadOnlyList<Value>, Value> func) => _functions[name] = func;
    
    public Value Get(string name) { /* ... */ }
    public Value Call(string name, IReadOnlyList<Value> args) { /* ... */ }
}
```

## 🧪 Testing

### Running Tests
```bash
cd CSharp
dotnet test ExpressionKit.Tests/ExpressionKit.Tests.csproj
```

### Test Coverage
Our test suite covers all critical functionality:
- ✅ Basic arithmetic and boolean operations
- ✅ Variable resolution and scoping
- ✅ Built-in and custom function calls
- ✅ String operations and type coercion
- ✅ Complex expressions and operator precedence
- ✅ Error handling and edge cases
- ✅ Token analysis and syntax highlighting
- ✅ Performance scenarios (compilation/evaluation)

## 🎮 Interactive Demo

Experience ExpressionKit in action:

```bash
cd CSharp/Examples/ExpressionKitDemo
dotnet run
```

The demo provides:
- 🎯 Pre-built expression examples
- 🎮 Interactive expression evaluation
- 🎨 Token analysis demonstration
- 📚 Built-in help and documentation

## 🔧 Advanced Usage

### Custom Environment Implementation
```csharp
public class GameEnvironment : IEnvironment
{
    private readonly Player _player;
    private readonly GameWorld _world;
    
    public GameEnvironment(Player player, GameWorld world)
    {
        _player = player;
        _world = world;
    }
    
    public Value Get(string name) => name switch
    {
        "player.health" => new Value(_player.Health),
        "player.mana" => new Value(_player.Mana),
        "world.time" => new Value(_world.GameTime),
        _ => throw new ExpressionException($"Unknown variable: {name}")
    };
    
    public Value Call(string name, IReadOnlyList<Value> args) => name switch
    {
        "distance" when args.Count == 2 => 
            new Value(Vector2.Distance(
                new Vector2((float)args[0].AsNumber(), (float)args[1].AsNumber()),
                _player.Position)),
        _ => throw new ExpressionException($"Unknown function: {name}")
    };
}

// Usage
var env = new GameEnvironment(player, world);
var healthCheck = Expression.Parse("player.health > 50 && distance(target.x, target.y) < 100");
if (healthCheck.Evaluate(env).AsBoolean())
{
    // Player is healthy and target is close
}
```

## 🚀 Performance Tips

1. **Pre-compile** expressions that are evaluated repeatedly
2. **Reuse** `IEnvironment` instances when possible
3. **Cache** `CompiledExpression` objects for frequently used formulas
4. **Minimize** token collection unless needed for syntax highlighting
5. **Use** appropriate value types (`AsNumber()` vs `AsString()`) consistently

## 📖 Further Reading

- [Main README](../README.md) - Complete project overview
- [C++ Reference](../ExpressionKit.hpp) - Original implementation
- [Swift Implementation](../Swift/) - Swift port documentation

## 🤝 Contributing

This C# implementation follows the 1:1 translation principle. When contributing:

1. Maintain identical behavior to the C++ reference
2. Follow .NET coding conventions and patterns
3. Update tests to match any C++ test changes
4. Verify cross-platform compatibility (.NET 8.0+)
5. Document any .NET-specific optimizations or patterns

## 📄 License

MIT License - see [LICENSE](../LICENSE) for details.