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

echo "Framework Reporting Differences:"
echo "  C++ (Catch2): $CPP_CASES test cases reported"
echo "  Swift (XCTest): $SWIFT_CASES test methods reported"
echo ""
echo "Analysis:"
if [ "$CPP_CASES" -eq "$SWIFT_CASES" ]; then
    echo -e "✅ ${GREEN}Test counts match perfectly!${NC}"
elif [ "$SWIFT_CASES" -gt "$CPP_CASES" ]; then
    DIFFERENCE=$(($SWIFT_CASES - $CPP_CASES))
    echo -e "📊 ${BLUE}Swift has $DIFFERENCE more test methods than C++ test cases${NC}"
    echo "   This is normal - different frameworks count tests differently:"
    echo "   • C++ Catch2 counts TEST_CASE declarations"
    echo "   • Swift XCTest counts individual test methods"
    echo "   • C++ may have multiple SECTION blocks within each TEST_CASE"
else
    DIFFERENCE=$(($CPP_CASES - $SWIFT_CASES))
    echo -e "📊 ${BLUE}C++ has $DIFFERENCE more test cases than Swift test methods${NC}"
    echo "   This could indicate missing Swift test coverage"
fi

echo ""

# Generate GitHub Actions summary
{
  echo "# 🧪 Enhanced Test Status Report"
  echo ""
  echo "## Test Results"
  echo "| Test Suite | Status | Reported Count | Details |"
  echo "|------------|--------|----------------|---------|"
  echo "| **C++ (Catch2)** | **$([ "$CPP_STATUS" = "PASSED" ] && echo "✅ PASSED" || echo "❌ FAILED")** | $CPP_CASES test cases | $CPP_ASSERTIONS assertions |"
  echo "| **Swift (XCTest)** | **$([ "$SWIFT_STATUS" = "PASSED" ] && echo "✅ PASSED" || echo "❌ FAILED")** | $SWIFT_CASES test methods | $SWIFT_FAILURES failures |"
  echo ""
  echo "## Test Count Analysis"
  echo ""
  if [ "$CPP_CASES" -eq "$SWIFT_CASES" ]; then
    echo "✅ **Test counts match perfectly!** Both frameworks report the same number."
  elif [ "$SWIFT_CASES" -gt "$CPP_CASES" ]; then
    DIFF=$(($SWIFT_CASES - $CPP_CASES))
    echo "📊 **Different counting methods detected:**"
    echo "- Swift reports $DIFF more test methods than C++ test cases"
    echo "- This is normal - frameworks count tests differently"
    echo "- C++ Catch2 counts TEST_CASE declarations"  
    echo "- Swift XCTest counts individual test methods"
    echo "- C++ may have multiple SECTION blocks within each TEST_CASE"
  else
    DIFF=$(($CPP_CASES - $SWIFT_CASES))
    echo "⚠️ **Potential test coverage gap:**"
    echo "- C++ has $DIFF more test cases than Swift test methods"
    echo "- This could indicate missing Swift test coverage"
  fi
  echo ""
  echo "*Last updated: $(date -u "+%Y-%m-%d %H:%M:%S UTC")*"
} >> $GITHUB_STEP_SUMMARY

echo -e "${GREEN}✅ Enhanced test analysis complete!${NC}"

# Clean up
rm -f cpp_test_output.txt swift_test_output.txt
rm -f cpp_test_status.txt cpp_test_cases.txt cpp_test_assertions.txt
rm -f swift_test_status.txt swift_test_cases.txt swift_test_failures.txt