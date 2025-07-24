#!/bin/bash

# Script to run C++ tests and capture results
# Usage: ./scripts/run_cpp_tests.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building C++ tests...${NC}"

# Change to CPP directory and build the tests
cd CPP
cmake . > /dev/null 2>&1
make ExprTKTest > /dev/null 2>&1

echo -e "${YELLOW}Running C++ tests...${NC}"

# Run tests and capture output
if ./ExprTKTest > ../cpp_test_output.txt 2>&1; then
    # Parse the output to get test statistics
    TOTAL_ASSERTIONS=$(grep "assertions in" ../cpp_test_output.txt | sed -n 's/.*(\([0-9]*\) assertions.*/\1/p')
    TOTAL_CASES=$(grep "test cases" ../cpp_test_output.txt | sed -n 's/.*in \([0-9]*\) test cases.*/\1/p')
    
    echo -e "${GREEN}✅ C++ Tests PASSED${NC}"
    echo "   📊 Test Cases: ${TOTAL_CASES}"
    echo "   🔍 Assertions: ${TOTAL_ASSERTIONS}"
    
    # Create status file (in root directory)
    cd ..
    echo "PASSED" > cpp_test_status.txt
    echo "${TOTAL_CASES}" > cpp_test_cases.txt
    echo "${TOTAL_ASSERTIONS}" > cpp_test_assertions.txt
    
    exit 0
else
    echo -e "${RED}❌ C++ Tests FAILED${NC}"
    cat ../cpp_test_output.txt
    
    # Create status file (in root directory)
    cd ..
    echo "FAILED" > cpp_test_status.txt
    echo "0" > cpp_test_cases.txt
    echo "0" > cpp_test_assertions.txt
    
    exit 1
fi