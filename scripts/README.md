# Test Scripts Documentation

This directory contains scripts for managing and reporting test status for the ExpressionKit project.

## Available Scripts

### `run_all_tests.sh`
Runs both C++ and Swift test suites and provides a summary.

```bash
./scripts/run_all_tests.sh
```

### `run_cpp_tests.sh`
Runs only the C++ (Catch2) test suite and captures results.

```bash
./scripts/run_cpp_tests.sh
```

### `run_swift_tests.sh`
Runs only the Swift (XCTest) test suite and captures results.

```bash
./scripts/run_swift_tests.sh
```

### `update_readme.sh`
Runs all tests and updates the README.md file with current test status.

```bash
./scripts/update_readme.sh
```

## Requirements

### For C++ Tests
- CMake 3.14+
- C++17 compatible compiler
- Internet connection (for downloading Catch2)

### For Swift Tests
- Swift 5.7+
- Swift Package Manager

## Test Status Display

The scripts automatically update the README.md with:
- Test status badges (PASSED/FAILED)
- Test case counts
- Assertion/failure counts
- Timestamp of last update
- Test coverage summary

## CI/CD Integration

The GitHub Actions workflow (`.github/workflows/update-test-status.yml`) automatically:
- Runs on pushes to main/master branches
- Runs on pull requests
- Can be manually triggered
- Updates README.md with current test status
- Commits changes back to the repository

## Output Files

The scripts create temporary files during execution:
- `cpp_test_output.txt` - C++ test output
- `swift_test_output.txt` - Swift test output
- `*_test_status.txt` - Test status files
- `*_test_cases.txt` - Test count files

These files are automatically cleaned up after use.