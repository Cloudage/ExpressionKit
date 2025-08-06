#!/bin/bash
# Enhanced Test Status Check with Detailed Explanation
# This script provides comprehensive test reporting with count explanations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 Enhanced Test Status Check${NC}"
echo ""

# Run existing test scripts
echo -e "${YELLOW}Running C++ tests...${NC}"
./scripts/run_cpp_tests.sh

echo -e "${YELLOW}Running Swift tests...${NC}"
./scripts/run_swift_tests.sh

# Read test results
CPP_STATUS=$(cat cpp_test_status.txt)
CPP_CASES=$(cat cpp_test_cases.txt)
CPP_ASSERTIONS=$(cat cpp_test_assertions.txt)

SWIFT_STATUS=$(cat swift_test_status.txt)
SWIFT_CASES=$(cat swift_test_cases.txt)
SWIFT_FAILURES=$(cat swift_test_failures.txt)

# Test count analysis
echo ""
echo -e "${BLUE}📋 Test Count Analysis${NC}"
echo ""

# Known test structure (from analysis)
CPP_TEST_CASES=28
CPP_SECTIONS=63
CPP_FUNCTIONAL_TESTS=91
SWIFT_TEST_METHODS=60

echo "Framework Reporting Differences:"
echo "  C++ (Catch2): $CPP_CASES test cases reported (ignores $CPP_SECTIONS sections)"
echo "  Swift (XCTest): $SWIFT_CASES test methods reported"
echo ""
echo "Functional Test Coverage:"
echo "  C++ Functional Units: $CPP_FUNCTIONAL_TESTS (TEST_CASE + SECTION)"
echo "  Swift Test Methods: $SWIFT_TEST_METHODS"
echo ""

# Coverage analysis
if [ "$SWIFT_TEST_METHODS" -ge "$CPP_FUNCTIONAL_TESTS" ]; then
    echo -e "✅ ${GREEN}Test Coverage: EXCELLENT${NC}"
    if [ "$SWIFT_TEST_METHODS" -gt "$CPP_FUNCTIONAL_TESTS" ]; then
        EXTRA=$(($SWIFT_TEST_METHODS - $CPP_FUNCTIONAL_TESTS))
        echo "  Swift has $EXTRA additional tests beyond C++ coverage"
    else
        echo "  Perfect 1:1 coverage of all C++ functional tests"
    fi
else
    MISSING=$(($CPP_FUNCTIONAL_TESTS - $SWIFT_TEST_METHODS))
    echo -e "⚠️ ${YELLOW}Test Coverage: $MISSING tests may be missing${NC}"
fi

echo ""

# Generate GitHub Actions summary
cat >> $GITHUB_STEP_SUMMARY << 'EOF'
# 🧪 Enhanced Test Status Report

## Test Results
| Test Suite | Status | Reported Count | Details |
|------------|--------|----------------|---------|
| **C++ (Catch2)** | **$([ "$CPP_STATUS" = "PASSED" ] && echo "✅ PASSED" || echo "❌ FAILED")** | $CPP_CASES test cases | $CPP_ASSERTIONS assertions |
| **Swift (XCTest)** | **$([ "$SWIFT_STATUS" = "PASSED" ] && echo "✅ PASSED" || echo "❌ FAILED")** | $SWIFT_CASES test methods | $SWIFT_FAILURES failures |

## Framework Counting Explanation

The difference in reported test counts is **expected and normal**:

- **C++ Catch2**: Reports only TEST_CASE declarations ($CPP_CASES), ignoring SECTION subdivisions
- **Swift XCTest**: Reports each test function individually ($SWIFT_CASES)

## Functional Test Coverage

| Metric | C++ | Swift | Status |
|--------|-----|-------|--------|
| Functional Test Units | $CPP_FUNCTIONAL_TESTS | $SWIFT_TEST_METHODS | $([ "$SWIFT_TEST_METHODS" -ge "$CPP_FUNCTIONAL_TESTS" ] && echo "✅ Complete" || echo "⚠️ Incomplete") |
| Framework Reports | $CPP_CASES | $SWIFT_CASES | Different counting methods |

*Last updated: $(date -u "+%Y-%m-%d %H:%M:%S UTC")*
EOF

echo -e "${GREEN}✅ Enhanced test analysis complete!${NC}"

# Clean up
rm -f cpp_test_output.txt swift_test_output.txt
rm -f cpp_test_status.txt cpp_test_cases.txt cpp_test_assertions.txt
rm -f swift_test_status.txt swift_test_cases.txt swift_test_failures.txt