# ExpressionKit TypeScript

A lightweight, interface-driven expression parser and evaluator for TypeScript, translated 1:1 from the C++ ExpressionKit implementation.

## 🚀 Quick Installation

### Option 1: One-line installer (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/Cloudage/ExpressionKit/main/scripts/install-typescript.sh | bash
```

### Option 2: Manual installation
```bash
git clone https://github.com/Cloudage/ExpressionKit.git
cd ExpressionKit/TypeScript
npm install && npm run build
# Copy dist files to your project
```

### Option 3: Using npm registry (when published)
```bash
npm install expressionkit-typescript
```

## 📖 Usage

```typescript
import { Expression, SimpleEnvironment, Value } from 'expressionkit-typescript';

// Simple arithmetic
const result = Expression.evalSimple('2 + 3 * 4'); // 14
console.log(result.asNumber()); // 14
```

For complete documentation, see [TYPESCRIPT_USAGE.md](../TYPESCRIPT_USAGE.md)

## 🏗️ Features

- **Value System**: Type-safe union (NUMBER/BOOLEAN/STRING) with conversions
- **IEnvironment**: Interface for variable/function resolution  
- **Expression**: Main API with `evalSimple()` and `parse()+evaluate()` methods
- **Token system**: For syntax highlighting capabilities
- **Built-in functions**: All mathematical functions from C++ reference

## 🧪 Testing

```bash
npm test
```

## 📝 License

MIT License - see [LICENSE](../LICENSE) for details.