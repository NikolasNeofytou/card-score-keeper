# Card Game Scorekeeper - Build and Run Script (PowerShell)
# This script handles both Flutter setup and running the application

param(
    [string]$Mode = "web",  # Options: web, mobile, docker
    [string]$Device = "",    # Specific device for mobile
    [switch]$Clean = $false,
    [switch]$Build = $false
)

Write-Host "Card Game Scorekeeper - Build and Run Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Check if Flutter is installed
function Test-Flutter {
    try {
        $null = flutter --version
        return $true
    }
    catch {
        Write-Host "Error: Flutter is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
        return $false
    }
}

# Clean build artifacts
function Clean-Build {
    Write-Host "`nCleaning build artifacts..." -ForegroundColor Yellow
    flutter clean
    Remove-Item -Path "pubspec.lock" -ErrorAction SilentlyContinue
    Write-Host "Clean complete!" -ForegroundColor Green
}

# Get Flutter dependencies
function Get-Dependencies {
    Write-Host "`nGetting Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error getting dependencies!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
}

# Run Flutter web
function Start-WebApp {
    Write-Host "`nStarting Flutter web application..." -ForegroundColor Yellow
    Write-Host "Opening at: http://localhost:5000" -ForegroundColor Cyan
    flutter run -d chrome --web-port=5000
}

# Build Flutter web
function Build-WebApp {
    Write-Host "`nBuilding Flutter web application..." -ForegroundColor Yellow
    flutter build web --release
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Web build complete! Output in: build/web" -ForegroundColor Green
    }
    else {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
}

# Run Flutter mobile
function Start-MobileApp {
    Write-Host "`nStarting Flutter mobile application..." -ForegroundColor Yellow
    
    if ($Device -ne "") {
        Write-Host "Running on device: $Device" -ForegroundColor Cyan
        flutter run -d $Device
    }
    else {
        # List available devices
        Write-Host "Available devices:" -ForegroundColor Cyan
        flutter devices
        Write-Host "`nStarting on default device..." -ForegroundColor Yellow
        flutter run
    }
}

# Run with Docker
function Start-Docker {
    Write-Host "`nStarting with Docker..." -ForegroundColor Yellow
    
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Docker is not installed!" -ForegroundColor Red
        Write-Host "Please install Docker from: https://www.docker.com/get-started" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Building Docker image..." -ForegroundColor Yellow
    docker-compose up --build
}

# Main execution
if (-not (Test-Flutter) -and $Mode -ne "docker") {
    exit 1
}

# Clean if requested
if ($Clean) {
    Clean-Build
}

# Get dependencies (unless running docker-only)
if ($Mode -ne "docker") {
    Get-Dependencies
}

# Execute based on mode
switch ($Mode.ToLower()) {
    "web" {
        if ($Build) {
            Build-WebApp
        }
        else {
            Start-WebApp
        }
    }
    "mobile" {
        Start-MobileApp
    }
    "docker" {
        Start-Docker
    }
    default {
        Write-Host "Invalid mode: $Mode" -ForegroundColor Red
        Write-Host "Valid modes: web, mobile, docker" -ForegroundColor Yellow
        Write-Host "`nExamples:" -ForegroundColor Cyan
        Write-Host "  .\build-and-run.ps1 -Mode web" -ForegroundColor White
        Write-Host "  .\build-and-run.ps1 -Mode web -Build" -ForegroundColor White
        Write-Host "  .\build-and-run.ps1 -Mode mobile -Device chrome" -ForegroundColor White
        Write-Host "  .\build-and-run.ps1 -Mode docker" -ForegroundColor White
        Write-Host "  .\build-and-run.ps1 -Mode web -Clean" -ForegroundColor White
        exit 1
    }
}

Write-Host "`nScript completed!" -ForegroundColor Green
