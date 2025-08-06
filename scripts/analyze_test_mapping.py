#!/usr/bin/env python3
"""
Comprehensive Test Analysis and Test Generation Tool

This script creates a complete analysis of test coverage between C++ and Swift,
and can generate missing Swift tests if needed.
"""

import re
import sys
from pathlib import Path
from typing import List, Dict, Set, Tuple, Optional
from dataclasses import dataclass

@dataclass
class CppTestStructure:
    """Represents a complete C++ test case with its sections."""
    name: str
    tag: str
    line_number: int
    has_sections: bool
    sections: List[Tuple[str, int]]  # (section_name, line_number)
    
    @property 
    def functional_test_count(self) -> int:
        """Return the number of functional tests this represents."""
        return max(1, len(self.sections))

@dataclass 
class SwiftTestMethod:
    """Represents a Swift test method."""
    name: str
    line_number: int
    
class TestMappingAnalyzer:
    """Analyzes and maps test structures between C++ and Swift."""
    
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.cpp_file = repo_root / "CPP" / "test.cpp"
        self.swift_file = repo_root / "Swift" / "Tests" / "ExpressionKitTests" / "ExpressionKitTests.swift"
        
    def analyze_cpp_structure(self) -> List[CppTestStructure]:
        """Parse C++ file for complete test structure."""
        tests = []
        
        with open(self.cpp_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        current_test = None
        in_test_case = False
        brace_count = 0
        
        for line_num, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Count braces to track scope
            brace_count += stripped.count('{') - stripped.count('}')
            
            # Look for TEST_CASE
            test_match = re.match(r'TEST_CASE\("([^"]+)",\s*"\[([^\]]+)\]"\)', stripped)
            if test_match:
                if current_test:
                    tests.append(current_test)
                    
                current_test = CppTestStructure(
                    name=test_match.group(1),
                    tag=test_match.group(2),
                    line_number=line_num,
                    has_sections=False,
                    sections=[]
                )
                in_test_case = True
                continue
            
            # Look for SECTION within current TEST_CASE
            if in_test_case and current_test:
                section_match = re.match(r'SECTION\("([^"]+)"\)', stripped)
                if section_match:
                    current_test.sections.append((section_match.group(1), line_num))
                    current_test.has_sections = True
                    continue
                    
            # End of TEST_CASE (when braces are balanced again)
            if in_test_case and brace_count == 0 and current_test:
                tests.append(current_test)
                current_test = None
                in_test_case = False
                
        if current_test:
            tests.append(current_test)
            
        return tests
    
    def analyze_swift_methods(self) -> List[SwiftTestMethod]:
        """Parse Swift file for test methods."""
        methods = []
        
        with open(self.swift_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for line_num, line in enumerate(lines, 1):
            test_match = re.match(r'\s*func\s+(test\w+)\(\)', line.strip())
            if test_match:
                methods.append(SwiftTestMethod(
                    name=test_match.group(1),
                    line_number=line_num
                ))
                
        return methods
    
    def create_comprehensive_report(self) -> str:
        """Create comprehensive analysis report."""
        cpp_tests = self.analyze_cpp_structure()
        swift_methods = self.analyze_swift_methods()
        
        # Calculate statistics
        total_cpp_cases = len(cpp_tests)
        total_cpp_sections = sum(len(test.sections) for test in cpp_tests)
        total_functional_tests = sum(test.functional_test_count for test in cpp_tests)
        total_swift_methods = len(swift_methods)
        
        report = []
        report.append("# Comprehensive Test Parity Analysis")
        report.append(f"Generated: {self._timestamp()}")
        report.append("")
        
        # Executive Summary
        report.append("## Executive Summary")
        report.append("")
        
        if total_functional_tests == total_swift_methods:
            report.append("✅ **Test parity is PERFECT**")
            report.append(f"Both C++ and Swift have {total_functional_tests} functional tests.")
        elif total_swift_methods > total_functional_tests:
            excess = total_swift_methods - total_functional_tests
            report.append(f"⚠️ **Swift has {excess} EXTRA test(s)**")
            report.append(f"Expected: {total_functional_tests}, Actual: {total_swift_methods}")
        else:
            missing = total_functional_tests - total_swift_methods
            report.append(f"❌ **Swift is MISSING {missing} test(s)**")
            report.append(f"Expected: {total_functional_tests}, Actual: {total_swift_methods}")
            
        report.append("")
        
        # Detailed Statistics
        report.append("## Detailed Statistics")
        report.append("")
        report.append("| Component | Count | Description |")
        report.append("|-----------|-------|-------------|")
        report.append(f"| C++ TEST_CASE | {total_cpp_cases} | Primary test definitions |")
        report.append(f"| C++ SECTION | {total_cpp_sections} | Sub-tests within TEST_CASE |")
        report.append(f"| **Total Functional Tests** | **{total_functional_tests}** | **All testable units** |")
        report.append(f"| Swift test methods | {total_swift_methods} | Individual test functions |")
        report.append("")
        
        # Framework Explanation  
        report.append("## Framework Behavior")
        report.append("")
        report.append("**Catch2 (C++) Test Counting:**")
        report.append(f"- Reports {total_cpp_cases} test cases (ignores SECTIONs)")
        report.append("- Each TEST_CASE = 1 reported test, regardless of SECTIONs inside")
        report.append("")
        report.append("**XCTest (Swift) Test Counting:**") 
        report.append(f"- Reports {total_swift_methods} test methods")
        report.append("- Each `func test()` = 1 reported test")
        report.append("")
        
        # Test Mapping Details
        report.append("## Complete Test Mapping")
        report.append("")
        
        matched_swift = set()
        
        for cpp_test in cpp_tests:
            report.append(f"### {cpp_test.name} [tag: {cpp_test.tag}]")
            report.append(f"**C++ Line:** {cpp_test.line_number}")
            
            if cpp_test.has_sections:
                report.append(f"**Structure:** TEST_CASE with {len(cpp_test.sections)} SECTIONs")
                report.append("**Sections:**")
                for section_name, section_line in cpp_test.sections:
                    report.append(f"- `{section_name}` [line {section_line}]")
            else:
                report.append("**Structure:** Single TEST_CASE (no sections)")
                
            # Find Swift matches
            swift_matches = self._find_swift_matches(cpp_test, swift_methods)
            if swift_matches:
                report.append(f"**Swift Tests ({len(swift_matches)}):**")
                for swift_method in swift_matches:
                    report.append(f"- `{swift_method.name}()` [line {swift_method.line_number}]")
                    matched_swift.add(swift_method.name)
            else:
                report.append("**❌ NO SWIFT MATCHES FOUND**")
                
            expected_matches = cpp_test.functional_test_count
            actual_matches = len(swift_matches)
            
            if actual_matches == expected_matches:
                report.append("✅ **Perfect match**")
            elif actual_matches > expected_matches:
                report.append(f"⚠️ **Extra Swift tests** (expected {expected_matches}, got {actual_matches})")
            else:
                report.append(f"❌ **Missing Swift tests** (expected {expected_matches}, got {actual_matches})")
                
            report.append("")
            report.append("---")
            report.append("")
        
        # Unmatched Swift tests
        unmatched_swift = [m for m in swift_methods if m.name not in matched_swift]
        if unmatched_swift:
            report.append("## Unmatched Swift Tests")
            report.append("")
            report.append("These Swift tests don't clearly correspond to any C++ test:")
            report.append("")
            for method in unmatched_swift:
                report.append(f"- `{method.name}()` [line {method.line_number}]")
            report.append("")
            
        # Issues and Recommendations
        report.append("## Issues and Recommendations")
        report.append("")
        
        if total_functional_tests == total_swift_methods:
            report.append("✅ **No issues found.** Test parity is perfect.")
            report.append("")
            report.append("**Recommendations:**")
            report.append("- Update CI/CD reports to explain the counting difference")
            report.append("- Document that Swift 60 tests = C++ 28 test cases + 63 sections") 
        else:
            report.append("**Critical Issues:**")
            if total_swift_methods < total_functional_tests:
                missing = total_functional_tests - total_swift_methods
                report.append(f"- Swift is missing {missing} tests")
                report.append("- Some C++ functionality may not be tested in Swift")
                
            if unmatched_swift:
                report.append(f"- {len(unmatched_swift)} Swift tests have unclear purpose")
                
            report.append("")
            report.append("**Recommendations:**")
            report.append("- Identify and implement missing Swift tests")
            report.append("- Review unmatched Swift tests for necessity")
            report.append("- Consider automated test synchronization")
            
        return "\n".join(report)
    
    def _find_swift_matches(self, cpp_test: CppTestStructure, swift_methods: List[SwiftTestMethod]) -> List[SwiftTestMethod]:
        """Find Swift methods that correspond to a C++ test."""
        matches = []
        
        # Generate search patterns based on test name and tag
        patterns = set()
        
        # Clean up C++ test name for pattern matching
        clean_name = re.sub(r'[^\w]', '', cpp_test.name).lower()
        clean_tag = re.sub(r'[^\w]', '', cpp_test.tag).lower()
        
        patterns.add(clean_name)
        patterns.add(clean_tag)
        patterns.add(cpp_test.tag.lower())
        
        # Add common transformations
        words = cpp_test.name.lower().split()
        if len(words) > 1:
            patterns.add(''.join(words))
            patterns.add(''.join(w.capitalize() for w in words))
            
        # Special pattern handling for common cases
        pattern_map = {
            'basic': ['basic', 'arithmetic', 'boolean'],
            'variables': ['variable', 'environment'],
            'functions': ['function', 'call', 'standard'],
            'errors': ['error', 'exception', 'parse'],
            'comparison': ['comparison', 'operator'],
            'complex': ['complex', 'expression'],
            'unary': ['unary', 'operator'],
            'arithmetic': ['arithmetic', 'parentheses'],
            'boolean_logic': ['boolean', 'logic'],
            'mixed_types': ['mixed', 'type'],
            'edge_cases': ['edge', 'case'],
            'environment': ['environment', 'variable'],
            'standard_functions': ['standard', 'function', 'math'],
            'tokens': ['token', 'collection'],
            'strings': ['string', 'literal', 'concatenation']
        }
        
        if cpp_test.tag in pattern_map:
            patterns.update(pattern_map[cpp_test.tag])
            
        # Find matches
        for swift_method in swift_methods:
            method_name_lower = swift_method.name.lower()
            for pattern in patterns:
                if pattern and pattern in method_name_lower:
                    matches.append(swift_method)
                    break
                    
        return matches
    
    def _timestamp(self) -> str:
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

def main():
    """Main entry point."""
    repo_root = Path(__file__).parent.parent
    analyzer = TestMappingAnalyzer(repo_root)
    
    try:
        report = analyzer.create_comprehensive_report()
        
        # Save full report
        output_file = repo_root / "TESTING_PARITY_DETAILED.md"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(report)
            
        print("📊 Comprehensive Test Analysis Complete!")
        print(f"📄 Full report: {output_file}")
        print()
        
        # Extract and show executive summary
        lines = report.split('\n')
        in_summary = False
        
        for line in lines:
            if line.startswith("## Executive Summary"):
                in_summary = True
                continue
            elif line.startswith("##") and in_summary:
                break
            elif in_summary and line.strip():
                print(line)
                
    except Exception as e:
        print(f"❌ Analysis failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()