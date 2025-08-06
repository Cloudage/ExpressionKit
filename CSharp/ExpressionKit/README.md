# ExpressionKit

A lightweight, interface-driven expression parser and evaluator for C# and .NET applications. Complete 1:1 translation from the C++ reference implementation.

## Quick Start

```csharp
using ExpressionKit;

// Simple evaluation
var result = Expression.Eval("2 + 3 * 4"); // 14.0

// With variables and functions
var env = new SimpleEnvironment();
env.SetVariable("x", 10.0);
env.SetFunction("double", args => new Value(args[0].AsNumber() * 2));

var advanced = Expression.Eval("double(x) > 15 ? \"Yes\" : \"No\"", env); // "Yes"
```

## Features

- **1:1 C++ Translation**: Identical behavior to reference C++ implementation
- **Interface-based Design**: Flexible variable and function access via `IEnvironment`
- **Pre-compiled Expressions**: Parse once, evaluate many times for performance
- **Token Analysis**: Complete syntax highlighting and IDE integration support
- **Type Safety**: Strong typing with automatic conversions between Number/Boolean/String
- **Zero Dependencies**: Pure .NET implementation

## Documentation

Visit [https://github.com/Cloudage/ExpressionKit](https://github.com/Cloudage/ExpressionKit) for complete documentation, examples, and source code.