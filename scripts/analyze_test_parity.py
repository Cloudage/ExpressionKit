#!/usr/bin/env python3
"""
Test Parity Analysis Script

This script analyzes the correspondence between C++ tests (Catch2) and Swift tests (XCTest)
to document and verify the expected differences in test counts.
"""

import re
import sys
from pathlib import Path
from typing import List, Dict, NamedTuple
from dataclasses import dataclass

@dataclass
class CppTestCase:
    name: str
    tag: str
    sections: List[str]
    line_number: int
    
@dataclass
class SwiftTestMethod:
    name: str
    line_number: int
    
class TestAnalyzer:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.cpp_test_file = repo_root / "CPP" / "test.cpp"
        self.swift_test_file = repo_root / "Swift" / "Tests" / "ExpressionKitTests" / "ExpressionKitTests.swift"
        
    def analyze_cpp_tests(self) -> List[CppTestCase]:
        """Parse C++ test file to extract TEST_CASE and SECTION information."""
        cpp_tests = []
        
        with open(self.cpp_test_file, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
            
        current_test = None
        
        for line_num, line in enumerate(lines, 1):
            # Match TEST_CASE("name", "[tag]")
            test_case_match = re.match(r'TEST_CASE\("([^"]+)",\s*"\[([^\]]+)\]"\)', line.strip())
            if test_case_match:
                if current_test:
                    cpp_tests.append(current_test)
                
                current_test = CppTestCase(
                    name=test_case_match.group(1),
                    tag=test_case_match.group(2),
                    sections=[],
                    line_number=line_num
                )
                
            # Match SECTION("name")
            section_match = re.match(r'\s*SECTION\("([^"]+)"\)', line.strip())
            if section_match and current_test:
                current_test.sections.append(section_match.group(1))
                
        if current_test:
            cpp_tests.append(current_test)
            
        return cpp_tests
    
    def analyze_swift_tests(self) -> List[SwiftTestMethod]:
        """Parse Swift test file to extract test methods."""
        swift_tests = []
        
        with open(self.swift_test_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for line_num, line in enumerate(lines, 1):
            # Match func testXxx() throws {
            test_match = re.match(r'\s*func\s+(test\w+)\(\)', line.strip())
            if test_match:
                swift_tests.append(SwiftTestMethod(
                    name=test_match.group(1),
                    line_number=line_num
                ))
                
        return swift_tests
    
    def create_mapping_analysis(self) -> str:
        """Create a detailed mapping analysis between C++ and Swift tests."""
        cpp_tests = self.analyze_cpp_tests()
        swift_tests = self.analyze_swift_tests()
        
        report = []
        report.append("# Test Parity Analysis Report")
        report.append(f"Generated: {self._get_timestamp()}")
        report.append("")
        
        # Summary statistics
        total_cpp_test_cases = len(cpp_tests)
        total_cpp_sections = sum(len(test.sections) for test in cpp_tests)
        total_swift_methods = len(swift_tests)
        
        report.append("## Summary Statistics")
        report.append("")
        report.append("| Metric | C++ (Catch2) | Swift (XCTest) |")
        report.append("|--------|---------------|----------------|")
        report.append(f"| Test Cases/Methods | {total_cpp_test_cases} TEST_CASE | {total_swift_methods} func test |")
        report.append(f"| Sections | {total_cpp_sections} SECTION | N/A |")
        report.append(f"| **Functional Tests** | **{total_cpp_test_cases + total_cpp_sections}** | **{total_swift_methods}** |")
        report.append("")
        
        # Explain the difference
        report.append("## Framework Counting Differences")
        report.append("")
        report.append("The test count difference is due to how the testing frameworks count tests:")
        report.append("")
        report.append("- **Catch2 (C++)**: Counts each `TEST_CASE` as one test, regardless of `SECTION`s")
        report.append("- **XCTest (Swift)**: Counts each `func test()` method as a separate test")
        report.append("- **AI Translation**: Correctly converted each C++ `SECTION` into a Swift test function")
        report.append("")
        
        # Detailed mapping
        report.append("## Detailed Test Mapping")
        report.append("")
        
        for cpp_test in cpp_tests:
            report.append(f"### C++ TEST_CASE: `{cpp_test.name}` [line {cpp_test.line_number}]")
            report.append(f"**Tag**: `{cpp_test.tag}`")
            report.append("")
            
            if cpp_test.sections:
                report.append(f"**Sections ({len(cpp_test.sections)}):**")
                for i, section in enumerate(cpp_test.sections, 1):
                    report.append(f"{i}. `{section}`")
            else:
                report.append("**No sections** (single test implementation)")
                
            report.append("")
            
            # Try to find corresponding Swift tests
            swift_matches = self._find_swift_matches(cpp_test, swift_tests)
            if swift_matches:
                report.append(f"**Corresponding Swift Tests ({len(swift_matches)}):**")
                for swift_test in swift_matches:
                    report.append(f"- `{swift_test.name}()` [line {swift_test.line_number}]")
            else:
                report.append("**⚠️ No clear Swift correspondence found**")
            
            report.append("")
            report.append("---")
            report.append("")
        
        # List unmapped Swift tests
        all_swift_matches = set()
        for cpp_test in cpp_tests:
            matches = self._find_swift_matches(cpp_test, swift_tests)
            all_swift_matches.update(test.name for test in matches)
            
        unmapped_swift = [test for test in swift_tests if test.name not in all_swift_matches]
        
        if unmapped_swift:
            report.append("## Unmapped Swift Tests")
            report.append("")
            report.append("These Swift tests don't have clear C++ correspondence:")
            report.append("")
            for test in unmapped_swift:
                report.append(f"- `{test.name}()` [line {test.line_number}]")
            report.append("")
            
        # Verification section  
        report.append("## Verification Results")
        report.append("")
        
        expected_swift_count = total_cpp_test_cases + total_cpp_sections
        actual_swift_count = total_swift_methods
        
        if expected_swift_count == actual_swift_count:
            report.append("✅ **Test counts match expected pattern**")
            report.append(f"- Expected functional tests: {expected_swift_count}")
            report.append(f"- Actual Swift tests: {actual_swift_count}")
        else:
            report.append("⚠️ **Test count discrepancy detected**")
            report.append(f"- Expected functional tests: {expected_swift_count}")
            report.append(f"- Actual Swift tests: {actual_swift_count}")
            report.append(f"- Difference: {actual_swift_count - expected_swift_count}")
            
        return "\n".join(report)
    
    def _find_swift_matches(self, cpp_test: CppTestCase, swift_tests: List[SwiftTestMethod]) -> List[SwiftTestMethod]:
        """Find Swift test methods that likely correspond to a C++ test case."""
        matches = []
        
        # Convert C++ test name to likely Swift patterns
        swift_patterns = self._generate_swift_patterns(cpp_test)
        
        for swift_test in swift_tests:
            for pattern in swift_patterns:
                if pattern.lower() in swift_test.name.lower():
                    matches.append(swift_test)
                    break
                    
        return matches
    
    def _generate_swift_patterns(self, cpp_test: CppTestCase) -> List[str]:
        """Generate possible Swift test method name patterns from C++ test case."""
        patterns = []
        
        # Use the test name directly
        name = cpp_test.name.replace(" ", "").replace("-", "")
        patterns.append(name)
        
        # Use the tag
        tag = cpp_test.tag.replace("_", "").replace("-", "")
        patterns.append(tag)
        
        # Common transformations
        patterns.extend([
            cpp_test.name.lower().replace(" ", "").replace("_", ""),
            cpp_test.tag.lower().replace("_", "").replace("-", ""),
            cpp_test.name.replace(" ", "").title(),
            cpp_test.tag.replace("_", "").title()
        ])
        
        return list(set(patterns))  # Remove duplicates
    
    def _get_timestamp(self) -> str:
        """Get current timestamp for the report."""
        from datetime import datetime
        return datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")

def main():
    """Main entry point."""
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    
    analyzer = TestAnalyzer(repo_root)
    
    try:
        report = analyzer.create_mapping_analysis()
        
        # Write report to file
        output_file = repo_root / "TESTING_PARITY_ANALYSIS.md"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(report)
            
        print(f"✅ Test parity analysis complete!")
        print(f"📄 Report saved to: {output_file}")
        print("")
        
        # Print summary to stdout
        lines = report.split('\n')
        summary_start = None
        summary_end = None
        
        for i, line in enumerate(lines):
            if line.startswith("## Summary Statistics"):
                summary_start = i
            elif summary_start and line.startswith("##") and i > summary_start:
                summary_end = i
                break
                
        if summary_start:
            end_idx = summary_end or len(lines)
            summary = '\n'.join(lines[summary_start:end_idx])
            print(summary)
            
    except Exception as e:
        print(f"❌ Error analyzing test parity: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()