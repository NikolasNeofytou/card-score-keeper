# Comprehensive Test Runner Script for Card Score Keeper (Windows PowerShell)
# This script runs all test categories with proper reporting

param(
    [Parameter(Position=0)]
    [ValidateSet("unit", "widget", "integration", "performance", "golden", "coverage", "analyze", "all")]
    [string]$TestType = "all"
)

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to run a test category
function Invoke-TestCategory {
    param(
        [string]$Category,
        [string]$Path,
        [string]$Description
    )
    
    Write-Status "Running $Description..."
    Write-Host "================================="
    
    if (Test-Path $Path) {
        $testFiles = Get-ChildItem -Path $Path -Filter "*.dart" -Recurse
        if ($testFiles.Count -gt 0) {
            try {
                $result = flutter test $Path --verbose
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "$Description completed successfully"
                    return $true
                } else {
                    Write-Error "$Description failed"
                    return $false
                }
            }
            catch {
                Write-Error "$Description failed with exception: $_"
                return $false
            }
        } else {
            Write-Warning "No tests found in $Path - skipping $Description"
            return $true
        }
    } else {
        Write-Warning "Directory $Path not found - skipping $Description"
        return $true
    }
    
    Write-Host ""
}

# Function to run tests with coverage
function Invoke-TestWithCoverage {
    param(
        [string]$Path,
        [string]$Description
    )
    
    Write-Status "Running $Description with coverage..."
    Write-Host "================================="
    
    if (Test-Path $Path) {
        $testFiles = Get-ChildItem -Path $Path -Filter "*.dart" -Recurse
        if ($testFiles.Count -gt 0) {
            try {
                $result = flutter test $Path --coverage --verbose
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "$Description with coverage completed successfully"
                    return $true
                } else {
                    Write-Error "$Description with coverage failed"
                    return $false
                }
            }
            catch {
                Write-Error "$Description with coverage failed with exception: $_"
                return $false
            }
        } else {
            Write-Warning "No tests found in $Path - skipping $Description"
            return $true
        }
    } else {
        Write-Warning "Directory $Path not found - skipping $Description"
        return $true
    }
    
    Write-Host ""
}

# Main execution function
function Invoke-ComprehensiveTests {
    Write-Status "Starting comprehensive test suite for Card Score Keeper"
    Write-Host "======================================================="
    Write-Host ""
    
    # Check if we're in a Flutter project
    if (-not (Test-Path "pubspec.yaml")) {
        Write-Error "Not in a Flutter project directory. Please run from project root."
        exit 1
    }
    
    # Get dependencies
    Write-Status "Getting Flutter dependencies..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to get Flutter dependencies"
        exit 1
    }
    
    # Generate build files if needed
    Write-Status "Generating build files..."
    if (Test-Path "build.yaml") {
        dart run build_runner build --delete-conflicting-outputs
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Build runner failed, continuing with tests..."
        }
    }
    
    # Run Flutter analyze
    Write-Status "Running Flutter analyze..."
    flutter analyze
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Flutter analyze completed successfully"
    } else {
        Write-Error "Flutter analyze failed"
        exit 1
    }
    
    Write-Host ""
    
    # Track test results
    $failedTests = @()
    
    # Run unit tests with coverage
    if (-not (Invoke-TestWithCoverage "test/unit/" "Unit Tests")) {
        $failedTests += "Unit Tests"
    }
    
    # Run widget tests
    if (-not (Invoke-TestCategory "widget" "test/widget/" "Widget Tests")) {
        $failedTests += "Widget Tests"
    }
    
    # Run integration tests
    if (-not (Invoke-TestCategory "integration" "test/integration/" "Integration Tests")) {
        $failedTests += "Integration Tests"
    }
    
    # Run performance tests
    if (-not (Invoke-TestCategory "performance" "test/performance/" "Performance Tests")) {
        $failedTests += "Performance Tests"
    }
    
    # Run golden file tests
    if (-not (Invoke-TestCategory "golden" "test/golden/" "Golden File Tests")) {
        $failedTests += "Golden File Tests"
    }
    
    # Generate coverage report if coverage data exists
    if (Test-Path "coverage/lcov.info") {
        Write-Status "Coverage data generated at coverage/lcov.info"
        Write-Status "Install lcov tools to generate HTML coverage report"
    }
    
    # Summary
    Write-Host ""
    Write-Host "======================================================="
    Write-Status "Test Suite Summary"
    Write-Host "======================================================="
    
    if ($failedTests.Count -eq 0) {
        Write-Success "All test categories passed successfully! 🎉"
        Write-Host ""
        Write-Status "Coverage information available in coverage/lcov.info"
        exit 0
    } else {
        Write-Error "The following test categories failed:"
        foreach ($test in $failedTests) {
            Write-Host "  - $test" -ForegroundColor Red
        }
        Write-Host ""
        Write-Error "Please fix the failing tests before proceeding."
        exit 1
    }
}

# Handle script arguments
switch ($TestType) {
    "unit" {
        Invoke-TestWithCoverage "test/unit/" "Unit Tests"
    }
    "widget" {
        Invoke-TestCategory "widget" "test/widget/" "Widget Tests"
    }
    "integration" {
        Invoke-TestCategory "integration" "test/integration/" "Integration Tests"
    }
    "performance" {
        Invoke-TestCategory "performance" "test/performance/" "Performance Tests"
    }
    "golden" {
        Invoke-TestCategory "golden" "test/golden/" "Golden File Tests"
    }
    "coverage" {
        Write-Status "Running all tests with coverage analysis..."
        flutter test --coverage
        if (Test-Path "coverage/lcov.info") {
            Write-Success "Coverage report available at coverage/lcov.info"
        }
    }
    "analyze" {
        flutter analyze
    }
    default {
        Invoke-ComprehensiveTests
    }
}