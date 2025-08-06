# Test Count Analysis and Explanation

## Why Test Counts Differ

The Swift and C++ test suites have different **reported** counts due to framework differences:

### C++ (Catch2) Framework
- **Reported Count**: 28 test cases
- **Structure**: 28 TEST_CASE + 63 SECTION
- **Actual Functional Tests**: 91
- **Counting Method**: Only counts `TEST_CASE` declarations, ignores `SECTION`s

### Swift (XCTest) Framework
- **Reported Count**: 60 test methods
- **Structure**: 60 individual `func test()` methods
- **Counting Method**: Each test function counts as one test

## Coverage Analysis

**Status**: ⚠️ NEEDS ATTENTION

Swift has 60 tests but should cover 91 functional units. 31 tests may be missing.

## Summary Comparison

| Aspect | C++ (Catch2) | Swift (XCTest) | Notes |
|--------|--------------|----------------|-------|
| Reported by Framework | 28 | 60 | What CI tools see |
| Functional Test Units | 91 | 60 | Actual test coverage |
| Framework Behavior | Counts TEST_CASE only | Counts each func test | Different counting rules |

## Recommendations for CI/CD

1. **Update test reports** to show both framework counts and functional coverage
2. **Document the expected difference** in project documentation
3. **Focus on functional parity** rather than raw counts
4. **Use this analysis** to verify test coverage completeness
