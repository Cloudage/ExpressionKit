#!/bin/bash

# Script to update README.md with current test status
# Usage: ./scripts/update_readme.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Updating README.md with test status...${NC}"

# Run both test suites
echo -e "${BLUE}Running test suites...${NC}"
./scripts/run_cpp_tests.sh
./scripts/run_swift_tests.sh

# Read test results
CPP_STATUS=$(cat cpp_test_status.txt)
CPP_CASES=$(cat cpp_test_cases.txt)
CPP_ASSERTIONS=$(cat cpp_test_assertions.txt)

SWIFT_STATUS=$(cat swift_test_status.txt)
SWIFT_CASES=$(cat swift_test_cases.txt)
SWIFT_FAILURES=$(cat swift_test_failures.txt)

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Create status badges
if [ "$CPP_STATUS" = "PASSED" ]; then
    CPP_BADGE="![C++ Tests](https://img.shields.io/badge/C%2B%2B%20Tests-PASSED-brightgreen)"
else
    CPP_BADGE="![C++ Tests](https://img.shields.io/badge/C%2B%2B%20Tests-FAILED-red)"
fi

if [ "$SWIFT_STATUS" = "PASSED" ]; then
    SWIFT_BADGE="![Swift Tests](https://img.shields.io/badge/Swift%20Tests-PASSED-brightgreen)"
else
    SWIFT_BADGE="![Swift Tests](https://img.shields.io/badge/Swift%20Tests-FAILED-red)"
fi

# Create test status section
TEST_STATUS_SECTION="## 🧪 Test Status

$CPP_BADGE $SWIFT_BADGE

### Test Results Summary

| Test Suite | Status | Test Cases | Details |
|------------|--------|------------|---------|
| **C++ (Catch2)** | **${CPP_STATUS}** | ${CPP_CASES} test cases | ${CPP_ASSERTIONS} assertions |
| **Swift (XCTest)** | **${SWIFT_STATUS}** | ${SWIFT_CASES} test cases | ${SWIFT_FAILURES} failures |

*Last updated: ${TIMESTAMP}*

### Test Coverage

- **C++ Core Library**: Comprehensive testing of the ExpressionKit.hpp functionality including arithmetic operations, boolean logic, comparison operators, error handling, and mathematical functions
- **Swift Wrapper**: Testing of the Swift API wrapper including type safety, memory management, performance characteristics, and error handling integration

Both test suites validate the correctness and reliability of the ExpressionKit library across different language interfaces."

# Check if test status section already exists
if grep -q "## 🧪 Test Status" README.md; then
    echo -e "${BLUE}Updating existing test status section...${NC}"
    # Use sed to replace everything from "## 🧪 Test Status" to the next "## " or end of file
    # Create a temporary file with the replacement
    awk -v new_section="$TEST_STATUS_SECTION" '
    /^## 🧪 Test Status/ {
        print new_section
        # Skip until next ## section or end of file
        while ((getline) > 0 && !/^## /) {
            # Skip lines
        }
        if (/^## /) {
            print $0  # Print the next section header
        }
        next
    }
    { print }
    ' README.md > README_temp.md && mv README_temp.md README.md
else
    echo -e "${BLUE}Adding new test status section...${NC}"
    # Insert after the first ## section (after Key Features)
    awk -v new_section="$TEST_STATUS_SECTION" '
    /^## 🤖 AI-Generated Code Notice/ {
        print new_section "\n"
        print $0
        next
    }
    { print }
    ' README.md > README_temp.md && mv README_temp.md README.md
fi

# Clean up temporary files
rm -f cpp_test_output.txt swift_test_output.txt
rm -f cpp_test_status.txt cpp_test_cases.txt cpp_test_assertions.txt
rm -f swift_test_status.txt swift_test_cases.txt swift_test_failures.txt

echo -e "${GREEN}✅ README.md updated successfully!${NC}"
echo -e "${BLUE}Test Status Summary:${NC}"
echo -e "   C++: ${CPP_STATUS} (${CPP_CASES} cases, ${CPP_ASSERTIONS} assertions)"
echo -e "   Swift: ${SWIFT_STATUS} (${SWIFT_CASES} cases, ${SWIFT_FAILURES} failures)"