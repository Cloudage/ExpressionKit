# ExpressionKit C# Quick Start Guide

This guide shows how to quickly integrate ExpressionKit into your C# projects using standard .NET package management.

## 🚀 Quick Integration

### Method 1: .NET CLI (Recommended)
```bash
dotnet add package Cloudage.ExpressionKit
```

### Method 2: Package Manager Console (Visual Studio)
```powershell
Install-Package Cloudage.ExpressionKit
```

### Method 3: PackageReference in .csproj
```xml
<PackageReference Include="Cloudage.ExpressionKit" Version="1.0.0" />
```

## 🧪 Instant Demo

Create a new console app and try ExpressionKit:

```bash
# Create new project
dotnet new console -n MyExpressionApp
cd MyExpressionApp

# Add ExpressionKit
dotnet add package Cloudage.ExpressionKit

# Replace Program.cs content with:
```

```csharp
using ExpressionKit;

// Simple math
Console.WriteLine($"2 + 3 * 4 = {Expression.Eval("2 + 3 * 4").AsNumber()}");

// Boolean logic  
Console.WriteLine($"5 > 3 && 2 < 10 = {Expression.Eval("5 > 3 && 2 < 10").AsBoolean()}");

// With variables
var env = new SimpleEnvironment();
env.SetVariable("radius", 5.0);
var area = Expression.Eval("3.14159 * radius * radius", env);
Console.WriteLine($"Circle area (r=5) = {area.AsNumber()}");

// Custom functions
env.SetFunction("square", args => new Value(args[0].AsNumber() * args[0].AsNumber()));
var result = Expression.Eval("square(4) + square(3)", env);
Console.WriteLine($"square(4) + square(3) = {result.AsNumber()}");
```

```bash
# Run it
dotnet run
```

## ✨ That's it! 

Just like Swift Package Manager, C# integration is now as simple as one command. The package includes:
- Zero external dependencies
- Complete documentation
- 18 comprehensive unit tests
- Interactive demo application
- Full source code compatibility with C++ and Swift implementations

## 📦 Package Features

- **Package ID**: `Cloudage.ExpressionKit`
- **Latest Version**: `1.0.0`
- **Target Framework**: `.NET 8.0+`
- **Dependencies**: None (zero dependencies)
- **Repository**: https://github.com/Cloudage/ExpressionKit