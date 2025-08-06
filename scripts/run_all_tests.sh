#!/bin/bash

# Script to run all tests
# Usage: ./scripts/run_all_tests.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 ExpressionKit Test Runner${NC}"
echo -e "${BLUE}=============================${NC}"

# Track overall success
OVERALL_SUCCESS=true

# Run C++ tests
echo -e "\n${YELLOW}📝 Running C++ (Catch2) Tests...${NC}"
./scripts/run_cpp_tests.sh
CPP_SUCCESS=$?
if [ $CPP_SUCCESS -ne 0 ]; then
    OVERALL_SUCCESS=false
fi

# Run Swift tests  
echo -e "\n${YELLOW}📝 Running Swift (XCTest) Tests...${NC}"
./scripts/run_swift_tests.sh
SWIFT_SUCCESS=$?
if [ $SWIFT_SUCCESS -ne 0 ]; then
    OVERALL_SUCCESS=false
fi

# Run TypeScript tests
echo -e "\n${YELLOW}📝 Running TypeScript (Jest) Tests...${NC}"
./scripts/run_typescript_tests.sh
TS_SUCCESS=$?
if [ $TS_SUCCESS -ne 0 ]; then
    OVERALL_SUCCESS=false
fi

# Print summary
echo -e "\n${GREEN}🎉 All tests completed!${NC}"
echo -e "${BLUE}Summary:${NC}"

if [ $CPP_SUCCESS -eq 0 ]; then
    echo -e "  ✅ C++ Tests: PASSED"
else
    echo -e "  ❌ C++ Tests: FAILED"
fi

if [ $SWIFT_SUCCESS -eq 0 ]; then
    echo -e "  ✅ Swift Tests: PASSED"
else
    echo -e "  ❌ Swift Tests: FAILED"
fi

if [ $TS_SUCCESS -eq 0 ]; then
    echo -e "  ✅ TypeScript Tests: PASSED"
else
    echo -e "  ❌ TypeScript Tests: FAILED"
fi

if [ "$OVERALL_SUCCESS" = true ]; then
    exit 0
else
    exit 1
fi