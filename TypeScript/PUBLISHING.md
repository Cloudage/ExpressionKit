# TypeScript Package Publishing Guide

This document provides instructions for publishing the ExpressionKit TypeScript package to npm registry, making it as easy to install as Swift Package Manager.

## 📦 Publishing to npm Registry

### Prerequisites

1. **npm account**: Create an account at [npmjs.com](https://npmjs.com)
2. **npm CLI**: Ensure you have npm installed and are logged in
   ```bash
   npm login
   ```

### Publishing Steps

1. **Navigate to TypeScript directory**:
   ```bash
   cd TypeScript
   ```

2. **Update version** (if needed):
   ```bash
   npm version patch  # or minor, major
   ```

3. **Build and test**:
   ```bash
   npm run clean
   npm install
   npm run build
   npm test
   ```

4. **Publish to npm**:
   ```bash
   npm publish
   ```

### Verification

After publishing, users can install with:
```bash
npm install expressionkit-typescript
```

## 🔧 Package Configuration

The package.json is already configured with:

- ✅ **Repository links**: Points to GitHub repository
- ✅ **Build scripts**: Includes `prepare` and `prepublishOnly` hooks
- ✅ **Type definitions**: Includes TypeScript declaration files
- ✅ **Files whitelist**: Only includes necessary files in package
- ✅ **Keywords**: Optimized for npm search
- ✅ **License**: MIT license specified

## 📋 Checklist Before Publishing

- [ ] All tests pass: `npm test`
- [ ] Documentation is up to date
- [ ] Version number is appropriate
- [ ] Package builds successfully: `npm run build`
- [ ] .npmignore excludes development files
- [ ] README.md is informative
- [ ] License is specified

## 🔄 Automated Publishing

Consider setting up GitHub Actions for automated publishing:

1. **On release tags**: Automatically publish when a new version tag is created
2. **On main branch**: Publish pre-release versions
3. **Manual trigger**: Allow manual publishing via workflow dispatch

This would make the TypeScript package as maintainable as the Swift Package Manager integration.