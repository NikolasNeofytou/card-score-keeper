#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Launch Android emulator and run Flutter app
.DESCRIPTION
    Starts the Android emulator if not running and launches the Flutter app
.PARAMETER DeviceId
    The device ID to use (default: emulator-5554)
.EXAMPLE
    .\launch-android-emulator.ps1
.EXAMPLE
    .\launch-android-emulator.ps1 -DeviceId emulator-5556
#>

param(
    [string]$DeviceId = "emulator-5554"
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

function Write-Step {
    param([string]$Message)
    Write-Host "🚀 $Message" -ForegroundColor $Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
}

# Check if Flutter is installed
Write-Step "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Flutter found"
    }
} catch {
    Write-Error "Flutter not found. Please install Flutter first."
    exit 1
}

# Check available emulators
Write-Step "Checking available emulators..."
$emulators = flutter emulators
if ($emulators -match "No emulators available") {
    Write-Error "No Android emulators found. Please create one using Android Studio."
    exit 1
}

# Check if emulator is already running
Write-Step "Checking if emulator is running..."
$devices = flutter devices
if ($devices -match $DeviceId) {
    Write-Success "Emulator $DeviceId is already running"
} else {
    Write-Warning "Emulator $DeviceId not found in running devices"
    Write-Step "Starting emulator..."
    
    # Try to start the emulator (this might take a while)
    Start-Process -FilePath "flutter" -ArgumentList "emulators", "--launch", "Medium_Phone_API_36.0" -NoNewWindow -Wait
    
    # Wait a bit for emulator to start
    Write-Step "Waiting for emulator to start..."
    Start-Sleep -Seconds 10
    
    # Check again
    $devices = flutter devices
    if ($devices -match $DeviceId) {
        Write-Success "Emulator started successfully"
    } else {
        Write-Error "Failed to start emulator"
        exit 1
    }
}

# Run Flutter app
Write-Step "Running Flutter app on $DeviceId..."
try {
    flutter run -d $DeviceId
    if ($LASTEXITCODE -eq 0) {
        Write-Success "App launched successfully!"
    } else {
        Write-Error "Failed to launch app"
    }
} catch {
    Write-Error "Error running Flutter app: $_"
}

# Keep the script window open if run directly
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Write-Host "`nPress any key to exit..." -ForegroundColor $Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}