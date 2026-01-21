#!/usr/bin/env bash

# test_runner.sh - Comprehensive test runner script for Flutter Card Scorekeeper
# Usage: ./test_runner.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COVERAGE_THRESHOLD=70
TEST_TIMEOUT=300 # 5 minutes
FLUTTER_VERSION="3.19.0"

# Flags
RUN_UNIT_TESTS=true
RUN_WIDGET_TESTS=true
RUN_INTEGRATION_TESTS=false
RUN_GOLDEN_TESTS=false
GENERATE_COVERAGE=true
UPDATE_GOLDENS=false
VERBOSE=false
WATCH_MODE=false

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Flutter Card Scorekeeper Test Runner

Usage: $0 [OPTIONS]

Options:
    -u, --unit-only           Run only unit tests
    -w, --widget-only        Run only widget tests
    -i, --integration        Run integration tests
    -g, --golden             Run golden file tests
    --update-goldens         Update golden files
    --no-coverage           Skip coverage generation
    --watch                 Run in watch mode
    -v, --verbose           Verbose output
    -h, --help              Show this help message

Examples:
    $0                      # Run all tests with coverage
    $0 -u                   # Run only unit tests
    $0 -w -g               # Run widget and golden tests
    $0 --watch             # Run in watch mode
    $0 --update-goldens    # Update golden files

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--unit-only)
            RUN_UNIT_TESTS=true
            RUN_WIDGET_TESTS=false
            RUN_INTEGRATION_TESTS=false
            RUN_GOLDEN_TESTS=false
            shift
            ;;
        -w|--widget-only)
            RUN_UNIT_TESTS=false
            RUN_WIDGET_TESTS=true
            RUN_INTEGRATION_TESTS=false
            RUN_GOLDEN_TESTS=false
            shift
            ;;
        -i|--integration)
            RUN_INTEGRATION_TESTS=true
            shift
            ;;
        -g|--golden)
            RUN_GOLDEN_TESTS=true
            shift
            ;;
        --update-goldens)
            UPDATE_GOLDENS=true
            RUN_GOLDEN_TESTS=true
            shift
            ;;
        --no-coverage)
            GENERATE_COVERAGE=false
            shift
            ;;
        --watch)
            WATCH_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Flutter version
    CURRENT_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")
    log_info "Flutter version: $CURRENT_VERSION"
    
    # Check if we're in a Flutter project
    if [[ ! -f "pubspec.yaml" ]]; then
        log_error "Not in a Flutter project directory"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Setup environment
setup_environment() {
    log_info "Setting up test environment..."
    
    # Clean previous build artifacts
    flutter clean
    
    # Get dependencies
    log_info "Getting dependencies..."
    flutter pub get
    
    # Generate required files
    log_info "Generating TypeAdapters and other generated files..."
    dart run build_runner build --delete-conflicting-outputs
    
    # Create coverage directory
    if [[ "$GENERATE_COVERAGE" == true ]]; then
        mkdir -p coverage
    fi
    
    log_success "Environment setup complete"
}

# Run code analysis
run_analysis() {
    log_info "Running code analysis..."
    
    # Flutter analyze
    log_info "Running flutter analyze..."
    if ! flutter analyze; then
        log_error "Flutter analyze failed"
        exit 1
    fi
    
    # Check formatting
    log_info "Checking code formatting..."
    if ! dart format --output=none --set-exit-if-changed .; then
        log_warning "Code formatting issues found. Run 'dart format .' to fix."
    fi
    
    log_success "Code analysis passed"
}

# Run unit tests
run_unit_tests() {
    if [[ "$RUN_UNIT_TESTS" != true ]]; then
        return 0
    fi
    
    log_info "Running unit tests..."
    
    local test_args=()
    
    if [[ "$GENERATE_COVERAGE" == true ]]; then
        test_args+=("--coverage")
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--reporter=expanded")
    fi
    
    if [[ "$WATCH_MODE" == true ]]; then
        test_args+=("--watch")
    fi
    
    # Add timeout
    test_args+=("--timeout=${TEST_TIMEOUT}s")
    
    if ! timeout "$TEST_TIMEOUT" flutter test "${test_args[@]}" test/unit/; then
        log_error "Unit tests failed"
        return 1
    fi
    
    log_success "Unit tests passed"
}

# Run widget tests
run_widget_tests() {
    if [[ "$RUN_WIDGET_TESTS" != true ]]; then
        return 0
    fi
    
    log_info "Running widget tests..."
    
    local test_args=()
    
    if [[ "$GENERATE_COVERAGE" == true ]]; then
        test_args+=("--coverage")
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--reporter=expanded")
    fi
    
    test_args+=("--timeout=${TEST_TIMEOUT}s")
    
    if ! timeout "$TEST_TIMEOUT" flutter test "${test_args[@]}" test/widget/; then
        log_error "Widget tests failed"
        return 1
    fi
    
    log_success "Widget tests passed"
}

# Run integration tests
run_integration_tests() {
    if [[ "$RUN_INTEGRATION_TESTS" != true ]]; then
        return 0
    fi
    
    log_info "Running integration tests..."
    
    if [[ ! -d "integration_test" ]]; then
        log_warning "No integration tests found"
        return 0
    fi
    
    if ! flutter test integration_test/; then
        log_error "Integration tests failed"
        return 1
    fi
    
    log_success "Integration tests passed"
}

# Run golden file tests
run_golden_tests() {
    if [[ "$RUN_GOLDEN_TESTS" != true ]]; then
        return 0
    fi
    
    log_info "Running golden file tests..."
    
    local test_args=()
    
    if [[ "$UPDATE_GOLDENS" == true ]]; then
        test_args+=("--update-goldens")
        log_info "Updating golden files..."
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--reporter=expanded")
    fi
    
    if [[ -d "test/golden" ]]; then
        if ! flutter test "${test_args[@]}" test/golden/; then
            log_error "Golden file tests failed"
            return 1
        fi
        log_success "Golden file tests passed"
    else
        log_warning "No golden file tests found"
    fi
}

# Generate coverage report
generate_coverage_report() {
    if [[ "$GENERATE_COVERAGE" != true ]] || [[ ! -f "coverage/lcov.info" ]]; then
        return 0
    fi
    
    log_info "Generating coverage report..."
    
    # Check if lcov is installed
    if command -v lcov &> /dev/null; then
        # Generate HTML report
        genhtml coverage/lcov.info -o coverage/html/
        log_success "HTML coverage report generated in coverage/html/"
    fi
    
    # Calculate coverage percentage
    if command -v lcov &> /dev/null; then
        COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -o "[0-9]\+\.[0-9]\+%" | head -1 | sed 's/%//')
        
        if [[ -n "$COVERAGE" ]]; then
            log_info "Coverage: ${COVERAGE}%"
            
            # Check coverage threshold
            if (( $(echo "$COVERAGE >= $COVERAGE_THRESHOLD" | bc -l) )); then
                log_success "Coverage threshold ($COVERAGE_THRESHOLD%) met"
            else
                log_warning "Coverage ($COVERAGE%) below threshold ($COVERAGE_THRESHOLD%)"
            fi
        fi
    else
        log_info "Coverage file generated: coverage/lcov.info"
        log_info "Install lcov for detailed coverage reports"
    fi
}

# Run performance tests
run_performance_tests() {
    log_info "Running performance checks..."
    
    # Check build size
    log_info "Checking build size..."
    flutter build web --release --tree-shake-icons > /dev/null 2>&1
    
    if [[ -d "build/web" ]]; then
        BUILD_SIZE=$(du -sh build/web | cut -f1)
        log_info "Web build size: $BUILD_SIZE"
    fi
    
    log_success "Performance checks completed"
}

# Clean up
cleanup() {
    log_info "Cleaning up..."
    
    # Remove temporary files
    if [[ -f "coverage/lcov.info.tmp" ]]; then
        rm coverage/lcov.info.tmp
    fi
    
    log_success "Cleanup completed"
}

# Main execution
main() {
    log_info "Starting Flutter Card Scorekeeper test runner"
    
    # Check prerequisites
    check_prerequisites
    
    # Setup environment
    setup_environment
    
    # Run analysis
    run_analysis
    
    local test_failures=0
    
    # Run tests
    if ! run_unit_tests; then
        ((test_failures++))
    fi
    
    if ! run_widget_tests; then
        ((test_failures++))
    fi
    
    if ! run_integration_tests; then
        ((test_failures++))
    fi
    
    if ! run_golden_tests; then
        ((test_failures++))
    fi
    
    # Generate coverage report
    generate_coverage_report
    
    # Run performance tests
    run_performance_tests
    
    # Cleanup
    cleanup
    
    # Summary
    if [[ $test_failures -eq 0 ]]; then
        log_success "All tests passed! ✅"
        exit 0
    else
        log_error "$test_failures test suite(s) failed ❌"
        exit 1
    fi
}

# Handle script interruption
trap 'log_warning "Test runner interrupted"; cleanup; exit 130' INT TERM

# Run main function
main "$@"