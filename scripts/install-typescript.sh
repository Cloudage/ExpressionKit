#!/bin/bash
# ExpressionKit TypeScript Installation Script
# This script installs ExpressionKit TypeScript directly from GitHub

set -e

echo "🔷 Installing ExpressionKit TypeScript..."

# Store current directory
INSTALL_DIR=$(pwd)

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone the repository
echo "📥 Downloading from GitHub..."
git clone --depth=1 https://github.com/Cloudage/ExpressionKit.git

# Navigate to TypeScript directory
cd ExpressionKit/TypeScript

# Build the package
echo "🔨 Building TypeScript package..."
npm install
npm run build

# Copy to user's node_modules (if they have a package.json)
if [ -f "$INSTALL_DIR/package.json" ]; then
    echo "📦 Installing to your project..."
    mkdir -p "$INSTALL_DIR/node_modules/expressionkit-typescript"
    cp -r dist/* "$INSTALL_DIR/node_modules/expressionkit-typescript/"
    cp package.json "$INSTALL_DIR/node_modules/expressionkit-typescript/"
    echo "✅ ExpressionKit TypeScript installed successfully!"
    echo "You can now use: import { Expression } from 'expressionkit-typescript';"
else
    echo "📁 No package.json found in current directory."
    echo "To install in your project, run this script from your project's root directory."
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"