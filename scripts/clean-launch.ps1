# Clean Flutter App Launch Script for Android
Write-Host "Starting clean Flutter launch for Android emulator..." -ForegroundColor Cyan

# Stop existing processes
Write-Host "Stopping existing Flutter processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*flutter*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean build cache
Write-Host "Cleaning Flutter cache..." -ForegroundColor Yellow
flutter clean

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# Check if emulator is running
Write-Host "Checking Android emulator status..." -ForegroundColor Yellow
$devices = flutter devices 2>&1
$emulatorRunning = $devices | Select-String "emulator-"

if (-not $emulatorRunning) {
    Write-Host "Starting Android emulator..." -ForegroundColor Yellow
    Write-Host "This may take a minute. Please wait..." -ForegroundColor Blue
    
    # Use the launch script we already have
    & ".\scripts\launch-android-emulator.ps1"
    
    # Brief wait for emulator to initialize
    Start-Sleep -Seconds 10
} else {
    Write-Host "Android emulator already running!" -ForegroundColor Green
}

# Launch with development flag for auto data clearing
Write-Host "Launching app with clean state on Android..." -ForegroundColor Green
flutter run --dart-define=DEVELOPMENT=true