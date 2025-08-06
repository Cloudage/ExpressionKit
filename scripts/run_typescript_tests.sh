#!/bin/bash
# TypeScript test runner script for ExpressionKit

echo "📝 Running TypeScript (Jest) Tests..."
echo "Building TypeScript tests..."

cd /home/runner/work/ExpressionKit/ExpressionKit/TypeScript

# Build the project
npm run build > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ TypeScript build failed"
    exit 1
fi

# Run tests
TEST_OUTPUT=$(npm test 2>&1)
TEST_EXIT_CODE=$?

echo "Running TypeScript tests..."

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ TypeScript Tests PASSED"
    
    # Extract test counts from Jest output
    PASSED_TESTS=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ passed' | grep -o '[0-9]\+' | head -1)
    TOTAL_TESTS=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ total' | grep -o '[0-9]\+' | head -1)
    FAILED_TESTS=$(echo "$TEST_OUTPUT" | grep -o '[0-9]\+ failed' | grep -o '[0-9]\+' | head -1)
    
    if [ -z "$FAILED_TESTS" ]; then
        FAILED_TESTS=0
    fi
    
    echo "   📊 Test Cases: ${TOTAL_TESTS:-0}"
    echo "   ✅ Passed: ${PASSED_TESTS:-0}"
    if [ "$FAILED_TESTS" -gt 0 ]; then
        echo "   ❌ Failed: $FAILED_TESTS"
    fi
    
    exit 0
else
    echo "❌ TypeScript Tests FAILED"
    echo "$TEST_OUTPUT"
    exit 1
fi