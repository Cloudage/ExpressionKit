# TypeScript Installation Guide

This guide shows how to install ExpressionKit TypeScript in your project as easily as Swift Package Manager.

## 🚀 Simple Installation Methods

### Option 1: One-line installer (Recommended after PR merge)

Once this PR is merged to main branch:
```bash
curl -sSL https://raw.githubusercontent.com/Cloudage/ExpressionKit/main/scripts/install-typescript.sh | bash
```

### Option 2: Manual installation from this PR branch

For testing the current PR:
```bash
# Clone this specific branch
git clone -b copilot/fix-38 https://github.com/Cloudage/ExpressionKit.git
cd ExpressionKit/TypeScript

# Build the package
npm install && npm run build

# Install to your project (run from your project's root directory)
mkdir -p ../your-project/node_modules/expressionkit-typescript
cp -r dist/* ../your-project/node_modules/expressionkit-typescript/
cp package.json ../your-project/node_modules/expressionkit-typescript/
```

### Option 3: Future npm registry

When published to npm registry:
```bash
npm install expressionkit-typescript
```

## 💡 Usage Example

Create a test file to verify the installation:

**test-expression.js**
```javascript
const { Expression, SimpleEnvironment, Value } = require('expressionkit-typescript');

// Test basic arithmetic
const result = Expression.evalSimple('2 + 3 * 4');
console.log('Result:', result.asNumber()); // Should output: Result: 14

// Test with variables
const env = new SimpleEnvironment();
env.setVariable('x', new Value(5));
env.setVariable('y', new Value(3));

const distance = Expression.evalSimple('sqrt(x*x + y*y)', env);
console.log('Distance:', distance.asNumber()); // Should output: Distance: 5.830459...

console.log('✅ ExpressionKit TypeScript is working correctly!');
```

Run with:
```bash
node test-expression.js
```

## 📊 Package Structure

After installation, you'll have:
```
node_modules/expressionkit-typescript/
├── ExpressionKit.js         # Main implementation
├── ExpressionKit.d.ts       # TypeScript definitions
├── SimpleEnvironment.js     # Ready-to-use environment
├── SimpleEnvironment.d.ts   # TypeScript definitions
├── index.js                 # Entry point
├── index.d.ts              # TypeScript definitions
└── package.json            # Package metadata
```

## 🎯 Swift Package Manager Comparison

This installation method achieves the same simplicity as Swift Package Manager:

| Aspect | Swift Package Manager | ExpressionKit TypeScript |
|--------|----------------------|---------------------------|
| **One Command** | `swift package add` | `curl ... \| bash` |
| **No Registry Needed** | ✅ Direct GitHub | ✅ Direct GitHub |
| **Auto Dependencies** | ✅ Handled by SPM | ✅ Handled by npm |
| **Ready to Import** | ✅ `import ExpressionKit` | ✅ `import { Expression }` |
| **Zero Config** | ✅ Works immediately | ✅ Works immediately |