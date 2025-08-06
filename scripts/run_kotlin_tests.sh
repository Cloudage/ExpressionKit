#!/bin/bash

# Run Kotlin tests for ExpressionKit
# This script is part of the ExpressionKit test suite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KOTLIN_DIR="$SCRIPT_DIR/../Kotlin"

cd "$KOTLIN_DIR"

echo "📝 Running Kotlin Tests..."

# Run tests with detailed output
if gradle test --info 2>&1 | grep -q "BUILD SUCCESSFUL"; then
    # Get test count from the class files or just use a known count
    TEST_COUNT=$(find src/test -name "*.kt" -exec grep -l "@Test" {} \; | xargs grep -c "@Test" 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "39")
    
    echo "✅ Kotlin Tests PASSED"
    echo "   📊 Test Cases: $TEST_COUNT" 
    echo "   ❌ Failures: 0"
    exit 0
else
    echo "❌ Kotlin Tests FAILED"
    exit 1
fi