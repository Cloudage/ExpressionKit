#!/bin/bash

# Script to run Swift tests and capture results
# Usage: ./scripts/run_swift_tests.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running Swift tests...${NC}"

# Run Swift tests and capture output
if swift test > swift_test_output.txt 2>&1; then
    # Parse the output to get test statistics
    # Look for pattern like "Executed 30 tests, with 0 failures"
    TOTAL_TESTS=$(grep "Executed.*tests" swift_test_output.txt | tail -1 | sed -n 's/.*Executed \([0-9]*\) tests.*/\1/p')
    FAILURES=$(grep "Executed.*tests" swift_test_output.txt | tail -1 | sed -n 's/.*with \([0-9]*\) failures.*/\1/p')
    
    if [ "$FAILURES" = "0" ]; then
        echo -e "${GREEN}✅ Swift Tests PASSED${NC}"
        echo "   📊 Test Cases: ${TOTAL_TESTS}"
        echo "   ❌ Failures: ${FAILURES}"
        
        # Create status file
        echo "PASSED" > swift_test_status.txt
        echo "${TOTAL_TESTS}" > swift_test_cases.txt
        echo "${FAILURES}" > swift_test_failures.txt
    else
        echo -e "${RED}❌ Swift Tests FAILED${NC}"
        echo "   📊 Test Cases: ${TOTAL_TESTS}"
        echo "   ❌ Failures: ${FAILURES}"
        
        # Create status file
        echo "FAILED" > swift_test_status.txt
        echo "${TOTAL_TESTS}" > swift_test_cases.txt
        echo "${FAILURES}" > swift_test_failures.txt
    fi
    
    exit 0
else
    echo -e "${RED}❌ Swift Tests FAILED${NC}"
    cat swift_test_output.txt
    
    # Create status file
    echo "FAILED" > swift_test_status.txt
    echo "0" > swift_test_cases.txt
    echo "1" > swift_test_failures.txt
    
    exit 1
fi