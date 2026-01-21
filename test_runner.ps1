# PowerShell Test Runner Script for Flutter Card Scorekeeper
# test_runner.ps1 - Windows compatible version of test_runner.sh
# Usage: .\test_runner.ps1 [options]

param(
    [switch]$UnitOnly,
    [switch]$WidgetOnly,
    [switch]$Integration,
    [switch]$Golden,
    [switch]$UpdateGoldens,
    [switch]$NoCoverage,
    [switch]$Watch,
    [switch]$Verbose,
    [switch]$Help
)

# Configuration
$CoverageThreshold = 70
$TestTimeout = 300 # 5 minutes
$FlutterVersion = "3.19.0"

# Flags
$RunUnitTests = $true
$RunWidgetTests = $true
$RunIntegrationTests = $false
$RunGoldenTests = $false
$GenerateCoverage = $true
$UpdateGoldensFlag = $false
$VerboseFlag = $false
$WatchMode = $false

# Colors for output
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

# Helper functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $ColorInfo
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $ColorSuccess
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $ColorWarning
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $ColorError
}

function Show-Help {
    @"
Flutter Card Scorekeeper Test Runner (PowerShell)

Usage: .\test_runner.ps1 [OPTIONS]

Options:
    -UnitOnly            Run only unit tests
    -WidgetOnly         Run only widget tests
    -Integration        Run integration tests
    -Golden             Run golden file tests
    -UpdateGoldens      Update golden files
    -NoCoverage         Skip coverage generation
    -Watch              Run in watch mode
    -Verbose            Verbose output
    -Help               Show this help message

Examples:
    .\test_runner.ps1                    # Run all tests with coverage
    .\test_runner.ps1 -UnitOnly         # Run only unit tests
    .\test_runner.ps1 -WidgetOnly -Golden # Run widget and golden tests
    .\test_runner.ps1 -Watch            # Run in watch mode
    .\test_runner.ps1 -UpdateGoldens    # Update golden files

"@
}

# Parse command line arguments
if ($Help) {
    Show-Help
    exit 0
}

if ($UnitOnly) {
    $RunUnitTests = $true
    $RunWidgetTests = $false
    $RunIntegrationTests = $false
    $RunGoldenTests = $false
}

if ($WidgetOnly) {
    $RunUnitTests = $false
    $RunWidgetTests = $true
    $RunIntegrationTests = $false
    $RunGoldenTests = $false
}

if ($Integration) {
    $RunIntegrationTests = $true
}

if ($Golden) {
    $RunGoldenTests = $true
}

if ($UpdateGoldens) {
    $UpdateGoldensFlag = $true
    $RunGoldenTests = $true
}

if ($NoCoverage) {
    $GenerateCoverage = $false
}

if ($Watch) {
    $WatchMode = $true
}

if ($Verbose) {
    $VerboseFlag = $true
}

# Check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check if Flutter is installed
    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutterCommand) {
        Write-Error "Flutter is not installed or not in PATH"
        exit 1
    }
    
    # Check Flutter version
    $versionOutput = flutter --version 2>&1 | Select-String "Flutter"
    Write-Info "Flutter version: $($versionOutput -replace 'Flutter ', '')"
    
    # Check if we're in a Flutter project
    if (-not (Test-Path "pubspec.yaml")) {
        Write-Error "Not in a Flutter project directory"
        exit 1
    }
    
    Write-Success "Prerequisites check passed"
}

# Setup environment
function Initialize-Environment {
    Write-Info "Setting up test environment..."
    
    # Clean previous build artifacts
    flutter clean | Out-Null
    
    # Get dependencies
    Write-Info "Getting dependencies..."
    flutter pub get | Out-Null
    
    # Generate required files
    Write-Info "Generating TypeAdapters and other generated files..."
    dart run build_runner build --delete-conflicting-outputs | Out-Null
    
    # Create coverage directory
    if ($GenerateCoverage) {
        New-Item -ItemType Directory -Force -Path "coverage" | Out-Null
    }
    
    Write-Success "Environment setup complete"
}

# Run code analysis
function Invoke-Analysis {
    Write-Info "Running code analysis..."
    
    # Flutter analyze
    Write-Info "Running flutter analyze..."
    $analyzeResult = flutter analyze 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Flutter analyze failed"
        Write-Host $analyzeResult
        exit 1
    }
    
    # Check formatting
    Write-Info "Checking code formatting..."
    $formatResult = dart format --output=none --set-exit-if-changed . 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Code formatting issues found. Run 'dart format .' to fix."
    }
    
    Write-Success "Code analysis passed"
}

# Run unit tests
function Invoke-UnitTests {
    if (-not $RunUnitTests) {
        return $true
    }
    
    Write-Info "Running unit tests..."
    
    $testArgs = @()
    
    if ($GenerateCoverage) {
        $testArgs += "--coverage"
    }
    
    if ($VerboseFlag) {
        $testArgs += "--reporter=expanded"
    }
    
    if ($WatchMode) {
        $testArgs += "--watch"
    }
    
    # Add timeout
    $testArgs += "--timeout=${TestTimeout}s"
    
    # Add test directory
    $testArgs += "test\unit\"
    
    $testResult = flutter test @testArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Unit tests failed"
        Write-Host $testResult
        return $false
    }
    
    Write-Success "Unit tests passed"
    return $true
}

# Run widget tests
function Invoke-WidgetTests {
    if (-not $RunWidgetTests) {
        return $true
    }
    
    Write-Info "Running widget tests..."
    
    $testArgs = @()
    
    if ($GenerateCoverage) {
        $testArgs += "--coverage"
    }
    
    if ($VerboseFlag) {
        $testArgs += "--reporter=expanded"
    }
    
    $testArgs += "--timeout=${TestTimeout}s"
    $testArgs += "test\widget\"
    
    $testResult = flutter test @testArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Widget tests failed"
        Write-Host $testResult
        return $false
    }
    
    Write-Success "Widget tests passed"
    return $true
}

# Run integration tests
function Invoke-IntegrationTests {
    if (-not $RunIntegrationTests) {
        return $true
    }
    
    Write-Info "Running integration tests..."
    
    if (-not (Test-Path "integration_test")) {
        Write-Warning "No integration tests found"
        return $true
    }
    
    $testResult = flutter test integration_test\ 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Integration tests failed"
        Write-Host $testResult
        return $false
    }
    
    Write-Success "Integration tests passed"
    return $true
}

# Run golden file tests
function Invoke-GoldenTests {
    if (-not $RunGoldenTests) {
        return $true
    }
    
    Write-Info "Running golden file tests..."
    
    $testArgs = @()
    
    if ($UpdateGoldensFlag) {
        $testArgs += "--update-goldens"
        Write-Info "Updating golden files..."
    }
    
    if ($VerboseFlag) {
        $testArgs += "--reporter=expanded"
    }
    
    if (Test-Path "test\golden") {
        $testArgs += "test\golden\"
        $testResult = flutter test @testArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Golden file tests failed"
            Write-Host $testResult
            return $false
        }
        Write-Success "Golden file tests passed"
    } else {
        Write-Warning "No golden file tests found"
    }
    
    return $true
}

# Generate coverage report
function New-CoverageReport {
    if (-not $GenerateCoverage -or -not (Test-Path "coverage\lcov.info")) {
        return
    }
    
    Write-Info "Generating coverage report..."
    
    # Try to generate HTML report if lcov is available (requires WSL or lcov.exe)
    $lcovCommand = Get-Command lcov -ErrorAction SilentlyContinue
    if ($lcovCommand) {
        try {
            genhtml coverage\lcov.info -o coverage\html\
            Write-Success "HTML coverage report generated in coverage\html\"
        } catch {
            Write-Warning "Could not generate HTML coverage report"
        }
        
        # Calculate coverage percentage
        try {
            $coverageOutput = lcov --summary coverage\lcov.info 2>&1 | Select-String "lines"
            if ($coverageOutput) {
                $coverage = [regex]::Match($coverageOutput, "(\d+\.\d+)%").Groups[1].Value
                
                if ($coverage) {
                    Write-Info "Coverage: ${coverage}%"
                    
                    # Check coverage threshold
                    if ([double]$coverage -ge $CoverageThreshold) {
                        Write-Success "Coverage threshold ($CoverageThreshold%) met"
                    } else {
                        Write-Warning "Coverage ($coverage%) below threshold ($CoverageThreshold%)"
                    }
                }
            }
        } catch {
            Write-Warning "Could not calculate coverage percentage"
        }
    } else {
        Write-Info "Coverage file generated: coverage\lcov.info"
        Write-Info "Install lcov for detailed coverage reports"
    }
}

# Run performance tests
function Invoke-PerformanceTests {
    Write-Info "Running performance checks..."
    
    # Check build size
    Write-Info "Checking build size..."
    flutter build web --release --tree-shake-icons 2>&1 | Out-Null
    
    if (Test-Path "build\web") {
        $buildSize = (Get-ChildItem -Path "build\web" -Recurse | Measure-Object -Property Length -Sum).Sum
        $buildSizeMB = [math]::Round($buildSize / 1MB, 2)
        Write-Info "Web build size: ${buildSizeMB} MB"
    }
    
    Write-Success "Performance checks completed"
}

# Clean up
function Clear-TestArtifacts {
    Write-Info "Cleaning up..."
    
    # Remove temporary files
    if (Test-Path "coverage\lcov.info.tmp") {
        Remove-Item "coverage\lcov.info.tmp" -Force
    }
    
    Write-Success "Cleanup completed"
}

# Main execution
function Main {
    Write-Info "Starting Flutter Card Scorekeeper test runner (PowerShell)"
    
    try {
        # Check prerequisites
        Test-Prerequisites
        
        # Setup environment
        Initialize-Environment
        
        # Run analysis
        Invoke-Analysis
        
        $testFailures = 0
        
        # Run tests
        if (-not (Invoke-UnitTests)) {
            $testFailures++
        }
        
        if (-not (Invoke-WidgetTests)) {
            $testFailures++
        }
        
        if (-not (Invoke-IntegrationTests)) {
            $testFailures++
        }
        
        if (-not (Invoke-GoldenTests)) {
            $testFailures++
        }
        
        # Generate coverage report
        New-CoverageReport
        
        # Run performance tests
        Invoke-PerformanceTests
        
        # Cleanup
        Clear-TestArtifacts
        
        # Summary
        if ($testFailures -eq 0) {
            Write-Success "All tests passed! ✅"
            exit 0
        } else {
            Write-Error "$testFailures test suite(s) failed ❌"
            exit 1
        }
    } catch {
        Write-Error "Test runner failed: $($_.Exception.Message)"
        Clear-TestArtifacts
        exit 1
    }
}

# Handle script interruption
trap {
    Write-Warning "Test runner interrupted"
    Clear-TestArtifacts
    exit 130
}

# Run main function
Main