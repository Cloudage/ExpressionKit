#!/bin/bash

# Script to run all tests
# Usage: ./scripts/run_all_tests.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 ExpressionKit Test Runner${NC}"
echo -e "${BLUE}=============================${NC}"

# Run C++ tests
echo -e "\n${YELLOW}📝 Running C++ (Catch2) Tests...${NC}"
./scripts/run_cpp_tests.sh

# Run Swift tests
echo -e "\n${YELLOW}📝 Running Swift (XCTest) Tests...${NC}"
./scripts/run_swift_tests.sh

# Run C# tests
echo -e "\n${YELLOW}📝 Running C# (XUnit) Tests...${NC}"
./scripts/run_csharp_tests.sh

echo -e "\n${GREEN}🎉 All tests completed successfully!${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  ✅ C++ Tests: PASSED"
echo -e "  ✅ Swift Tests: PASSED"
echo -e "  ✅ C# Tests: PASSED"