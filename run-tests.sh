#!/bin/bash

# Comprehensive Test Runner Script for Card Score Keeper
# This script runs all test categories with proper reporting

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run a test category
run_test_category() {
    local category=$1
    local path=$2
    local description=$3
    
    print_status "Running $description..."
    echo "================================="
    
    if [ -d "$path" ] && [ "$(ls -A $path 2>/dev/null)" ]; then
        if flutter test "$path" --verbose; then
            print_success "$description completed successfully"
        else
            print_error "$description failed"
            return 1
        fi
    else
        print_warning "No tests found in $path - skipping $description"
    fi
    
    echo ""
}

# Function to run tests with coverage
run_with_coverage() {
    local path=$1
    local description=$2
    
    print_status "Running $description with coverage..."
    echo "================================="
    
    if [ -d "$path" ] && [ "$(ls -A $path 2>/dev/null)" ]; then
        if flutter test "$path" --coverage --verbose; then
            print_success "$description with coverage completed successfully"
        else
            print_error "$description with coverage failed"
            return 1
        fi
    else
        print_warning "No tests found in $path - skipping $description"
    fi
    
    echo ""
}

# Main execution
main() {
    print_status "Starting comprehensive test suite for Card Score Keeper"
    echo "======================================================="
    echo ""
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory. Please run from project root."
        exit 1
    fi
    
    # Get dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate build files if needed
    print_status "Generating build files..."
    if [ -f "build.yaml" ]; then
        dart run build_runner build --delete-conflicting-outputs
    fi
    
    # Run Flutter analyze
    print_status "Running Flutter analyze..."
    if flutter analyze; then
        print_success "Flutter analyze completed successfully"
    else
        print_error "Flutter analyze failed"
        exit 1
    fi
    
    echo ""
    
    # Track test results
    declare -a failed_tests=()
    
    # Run unit tests with coverage
    if ! run_with_coverage "test/unit/" "Unit Tests"; then
        failed_tests+=("Unit Tests")
    fi
    
    # Run widget tests
    if ! run_test_category "widget" "test/widget/" "Widget Tests"; then
        failed_tests+=("Widget Tests")
    fi
    
    # Run integration tests
    if ! run_test_category "integration" "test/integration/" "Integration Tests"; then
        failed_tests+=("Integration Tests")
    fi
    
    # Run performance tests
    if ! run_test_category "performance" "test/performance/" "Performance Tests"; then
        failed_tests+=("Performance Tests")
    fi
    
    # Run golden file tests
    if ! run_test_category "golden" "test/golden/" "Golden File Tests"; then
        failed_tests+=("Golden File Tests")
    fi
    
    # Generate coverage report if coverage data exists
    if [ -f "coverage/lcov.info" ]; then
        print_status "Generating coverage report..."
        if command -v genhtml >/dev/null 2>&1; then
            genhtml coverage/lcov.info -o coverage/html
            print_success "Coverage report generated at coverage/html/index.html"
        else
            print_warning "genhtml not found. Install lcov to generate HTML coverage report."
        fi
    fi
    
    # Summary
    echo ""
    echo "======================================================="
    print_status "Test Suite Summary"
    echo "======================================================="
    
    if [ ${#failed_tests[@]} -eq 0 ]; then
        print_success "All test categories passed successfully! 🎉"
        echo ""
        print_status "Coverage information:"
        if [ -f "coverage/lcov.info" ]; then
            # Extract coverage percentage
            if command -v lcov >/dev/null 2>&1; then
                coverage_summary=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines......")
                print_status "$coverage_summary"
            fi
        fi
        exit 0
    else
        print_error "The following test categories failed:"
        for test in "${failed_tests[@]}"; do
            echo "  - $test"
        done
        echo ""
        print_error "Please fix the failing tests before proceeding."
        exit 1
    fi
}

# Handle script arguments
case "${1:-all}" in
    "unit")
        run_with_coverage "test/unit/" "Unit Tests"
        ;;
    "widget")
        run_test_category "widget" "test/widget/" "Widget Tests"
        ;;
    "integration")
        run_test_category "integration" "test/integration/" "Integration Tests"
        ;;
    "performance")
        run_test_category "performance" "test/performance/" "Performance Tests"
        ;;
    "golden")
        run_test_category "golden" "test/golden/" "Golden File Tests"
        ;;
    "coverage")
        print_status "Running all tests with coverage analysis..."
        flutter test --coverage
        if [ -f "coverage/lcov.info" ] && command -v genhtml >/dev/null 2>&1; then
            genhtml coverage/lcov.info -o coverage/html
            print_success "Coverage report available at coverage/html/index.html"
        fi
        ;;
    "analyze")
        flutter analyze
        ;;
    "all"|*)
        main
        ;;
esac