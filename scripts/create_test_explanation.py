#!/usr/bin/env python3
"""
Test Count Explanation and CI Enhancement

This script creates an enhanced test reporting system that explains the difference
in test counts between C++ and Swift, providing clear documentation for CI/CD.
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, Any

class TestCountAnalyzer:
    """Analyzes and explains test count differences between C++ and Swift."""
    
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.cpp_file = repo_root / "CPP" / "test.cpp"  
        self.swift_file = repo_root / "Swift" / "Tests" / "ExpressionKitTests" / "ExpressionKitTests.swift"
        
    def get_cpp_stats(self) -> Dict[str, Any]:
        """Get C++ test statistics."""
        with open(self.cpp_file, 'r') as f:
            content = f.read()
            
        test_cases = len([line for line in content.split('\n') if 'TEST_CASE(' in line])
        sections = len([line for line in content.split('\n') if 'SECTION(' in line])
        
        return {
            'test_cases': test_cases,
            'sections': sections,
            'functional_tests': test_cases + sections,
            'framework': 'Catch2',
            'reported_count': test_cases  # Catch2 only reports TEST_CASE count
        }
    
    def get_swift_stats(self) -> Dict[str, Any]:
        """Get Swift test statistics."""
        with open(self.swift_file, 'r') as f:
            content = f.read()
            
        test_methods = len([line for line in content.split('\n') if 'func test' in line])
        
        return {
            'test_methods': test_methods,
            'framework': 'XCTest',
            'reported_count': test_methods  # XCTest reports all test methods
        }
    
    def create_explanation_report(self) -> str:
        """Create a comprehensive explanation of the test count differences."""
        cpp_stats = self.get_cpp_stats()
        swift_stats = self.get_swift_stats()
        
        report = []
        report.append("# Test Count Analysis and Explanation")
        report.append("")
        
        # Framework explanation
        report.append("## Why Test Counts Differ")
        report.append("")
        report.append("The Swift and C++ test suites have different **reported** counts due to framework differences:")
        report.append("")
        
        report.append("### C++ (Catch2) Framework")
        report.append(f"- **Reported Count**: {cpp_stats['reported_count']} test cases")
        report.append(f"- **Structure**: {cpp_stats['test_cases']} TEST_CASE + {cpp_stats['sections']} SECTION")
        report.append(f"- **Actual Functional Tests**: {cpp_stats['functional_tests']}")
        report.append("- **Counting Method**: Only counts `TEST_CASE` declarations, ignores `SECTION`s")
        report.append("")
        
        report.append("### Swift (XCTest) Framework") 
        report.append(f"- **Reported Count**: {swift_stats['reported_count']} test methods")
        report.append(f"- **Structure**: {swift_stats['test_methods']} individual `func test()` methods")
        report.append("- **Counting Method**: Each test function counts as one test")
        report.append("")
        
        # Analysis of the situation
        cpp_functional = cpp_stats['functional_tests']
        swift_actual = swift_stats['test_methods']
        
        if swift_actual >= cpp_functional:
            coverage_status = "✅ EXCELLENT"
            explanation = f"Swift has {swift_actual} tests covering {cpp_functional} C++ functional units."
            if swift_actual > cpp_functional:
                explanation += f" The extra {swift_actual - cpp_functional} tests provide additional Swift-specific coverage."
        else:
            coverage_status = "⚠️ NEEDS ATTENTION" 
            missing = cpp_functional - swift_actual
            explanation = f"Swift has {swift_actual} tests but should cover {cpp_functional} functional units. {missing} tests may be missing."
        
        report.append("## Coverage Analysis")
        report.append("")
        report.append(f"**Status**: {coverage_status}")
        report.append("")
        report.append(explanation)
        report.append("")
        
        # Summary table
        report.append("## Summary Comparison")
        report.append("")
        report.append("| Aspect | C++ (Catch2) | Swift (XCTest) | Notes |")
        report.append("|--------|--------------|----------------|-------|")
        report.append(f"| Reported by Framework | {cpp_stats['reported_count']} | {swift_stats['reported_count']} | What CI tools see |")
        report.append(f"| Functional Test Units | {cpp_stats['functional_tests']} | {swift_stats['test_methods']} | Actual test coverage |")
        report.append(f"| Framework Behavior | Counts TEST_CASE only | Counts each func test | Different counting rules |")
        report.append("")
        
        # Recommendations
        report.append("## Recommendations for CI/CD")
        report.append("")
        report.append("1. **Update test reports** to show both framework counts and functional coverage")
        report.append("2. **Document the expected difference** in project documentation")
        report.append("3. **Focus on functional parity** rather than raw counts")
        report.append("4. **Use this analysis** to verify test coverage completeness")
        report.append("")
        
        return "\n".join(report)
        
    def create_ci_enhancement_script(self) -> str:
        """Create an enhanced CI script that explains test count differences."""
        cpp_stats = self.get_cpp_stats()
        swift_stats = self.get_swift_stats()
        
        # Create the script content step by step to avoid variable interpolation issues
        script_lines = [
            "#!/bin/bash",
            "# Enhanced Test Status Check with Detailed Explanation",
            "# This script provides comprehensive test reporting with count explanations",
            "",
            "set -e",
            "",
            "# Colors for output",
            "RED='\\033[0;31m'",
            "GREEN='\\033[0;32m'",
            "YELLOW='\\033[1;33m'",
            "BLUE='\\033[0;34m'",
            "NC='\\033[0m'",
            "",
            "echo -e \"${BLUE}📊 Enhanced Test Status Check${NC}\"",
            "echo \"\"",
            "",
            "# Run existing test scripts",
            "echo -e \"${YELLOW}Running C++ tests...${NC}\"",
            "./scripts/run_cpp_tests.sh",
            "",
            "echo -e \"${YELLOW}Running Swift tests...${NC}\"", 
            "./scripts/run_swift_tests.sh",
            "",
            "# Read test results",
            "CPP_STATUS=$(cat cpp_test_status.txt)",
            "CPP_CASES=$(cat cpp_test_cases.txt)",
            "CPP_ASSERTIONS=$(cat cpp_test_assertions.txt)",
            "",
            "SWIFT_STATUS=$(cat swift_test_status.txt)",
            "SWIFT_CASES=$(cat swift_test_cases.txt)",
            "SWIFT_FAILURES=$(cat swift_test_failures.txt)",
            "",
            "# Test count analysis",
            "echo \"\"",
            "echo -e \"${BLUE}📋 Test Count Analysis${NC}\"",
            "echo \"\"",
            "",
            f"# Known test structure (from analysis)",
            f"CPP_TEST_CASES={cpp_stats['test_cases']}",
            f"CPP_SECTIONS={cpp_stats['sections']}",
            f"CPP_FUNCTIONAL_TESTS={cpp_stats['functional_tests']}",
            f"SWIFT_TEST_METHODS={swift_stats['test_methods']}",
            "",
            "echo \"Framework Reporting Differences:\"",
            "echo \"  C++ (Catch2): $CPP_CASES test cases reported (ignores $CPP_SECTIONS sections)\"",
            "echo \"  Swift (XCTest): $SWIFT_CASES test methods reported\"",
            "echo \"\"",
            "echo \"Functional Test Coverage:\"",
            "echo \"  C++ Functional Units: $CPP_FUNCTIONAL_TESTS (TEST_CASE + SECTION)\"",
            "echo \"  Swift Test Methods: $SWIFT_TEST_METHODS\"",
            "echo \"\"",
            "",
            "# Coverage analysis",
            "if [ \"$SWIFT_TEST_METHODS\" -ge \"$CPP_FUNCTIONAL_TESTS\" ]; then",
            "    echo -e \"✅ ${GREEN}Test Coverage: EXCELLENT${NC}\"",
            "    if [ \"$SWIFT_TEST_METHODS\" -gt \"$CPP_FUNCTIONAL_TESTS\" ]; then",
            "        EXTRA=$(($SWIFT_TEST_METHODS - $CPP_FUNCTIONAL_TESTS))",
            "        echo \"  Swift has $EXTRA additional tests beyond C++ coverage\"",
            "    else",
            "        echo \"  Perfect 1:1 coverage of all C++ functional tests\"",
            "    fi",
            "else",
            "    MISSING=$(($CPP_FUNCTIONAL_TESTS - $SWIFT_TEST_METHODS))",
            "    echo -e \"⚠️ ${YELLOW}Test Coverage: $MISSING tests may be missing${NC}\"",
            "fi",
            "",
            "echo \"\"",
            "",
            "# Generate GitHub Actions summary",
            "cat >> $GITHUB_STEP_SUMMARY << 'EOF'",
            "# 🧪 Enhanced Test Status Report",
            "",
            "## Test Results",
            "| Test Suite | Status | Reported Count | Details |",
            "|------------|--------|----------------|---------|",
            "| **C++ (Catch2)** | **$([ \"$CPP_STATUS\" = \"PASSED\" ] && echo \"✅ PASSED\" || echo \"❌ FAILED\")** | $CPP_CASES test cases | $CPP_ASSERTIONS assertions |",
            "| **Swift (XCTest)** | **$([ \"$SWIFT_STATUS\" = \"PASSED\" ] && echo \"✅ PASSED\" || echo \"❌ FAILED\")** | $SWIFT_CASES test methods | $SWIFT_FAILURES failures |",
            "",
            "## Framework Counting Explanation",
            "",
            "The difference in reported test counts is **expected and normal**:",
            "",
            "- **C++ Catch2**: Reports only TEST_CASE declarations ($CPP_CASES), ignoring SECTION subdivisions",
            "- **Swift XCTest**: Reports each test function individually ($SWIFT_CASES)",
            "",
            "## Functional Test Coverage",
            "",
            "| Metric | C++ | Swift | Status |",
            "|--------|-----|-------|--------|",
            "| Functional Test Units | $CPP_FUNCTIONAL_TESTS | $SWIFT_TEST_METHODS | $([ \"$SWIFT_TEST_METHODS\" -ge \"$CPP_FUNCTIONAL_TESTS\" ] && echo \"✅ Complete\" || echo \"⚠️ Incomplete\") |",
            "| Framework Reports | $CPP_CASES | $SWIFT_CASES | Different counting methods |",
            "",
            "*Last updated: $(date -u \"+%Y-%m-%d %H:%M:%S UTC\")*",
            "EOF",
            "",
            "echo -e \"${GREEN}✅ Enhanced test analysis complete!${NC}\"",
            "",
            "# Clean up",
            "rm -f cpp_test_output.txt swift_test_output.txt",
            "rm -f cpp_test_status.txt cpp_test_cases.txt cpp_test_assertions.txt",
            "rm -f swift_test_status.txt swift_test_cases.txt swift_test_failures.txt"
        ]
        
        return "\n".join(script_lines)

def main():
    """Main entry point."""
    repo_root = Path(".")
    analyzer = TestCountAnalyzer(repo_root)
    
    try:
        # Create explanation report
        report = analyzer.create_explanation_report()
        report_file = repo_root / "TEST_COUNT_EXPLANATION.md"
        with open(report_file, 'w') as f:
            f.write(report)
        
        # Create enhanced CI script
        ci_script = analyzer.create_ci_enhancement_script()
        ci_file = repo_root / "scripts" / "enhanced_test_check.sh"
        with open(ci_file, 'w') as f:
            f.write(ci_script)
        ci_file.chmod(0o755)
        
        print("✅ Test count analysis and CI enhancement complete!")
        print(f"📄 Explanation report: {report_file}")
        print(f"🔧 Enhanced CI script: {ci_file}")
        print()
        
        # Show key findings
        cpp_stats = analyzer.get_cpp_stats()
        swift_stats = analyzer.get_swift_stats()
        
        print("Key Findings:")
        print(f"  C++ reports {cpp_stats['reported_count']} tests (Catch2 behavior)")
        print(f"  Swift reports {swift_stats['reported_count']} tests (XCTest behavior)")
        print(f"  C++ has {cpp_stats['functional_tests']} functional test units")
        print(f"  Swift has {swift_stats['test_methods']} test methods")
        
        if swift_stats['test_methods'] >= cpp_stats['functional_tests']:
            print("  ✅ Test coverage is adequate or better")
        else:
            missing = cpp_stats['functional_tests'] - swift_stats['test_methods']
            print(f"  ⚠️ {missing} Swift tests may be missing")
            
    except Exception as e:
        print(f"❌ Enhancement failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()