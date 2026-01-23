# Flutter Web Launch Script
# Kills existing processes and launches Flutter on port 3000

param(
    [int]$Port = 3000,
    [switch]$Debug = $false
)

Write-Host "🔥 Flutter Web Launcher" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# Function to kill processes on specific ports
function Kill-ProcessOnPort {
    param([int]$PortNumber)
    
    try {
        $processInfo = netstat -ano | findstr ":$PortNumber " | Select-String "LISTENING"
        if ($processInfo) {
            $processInfo | ForEach-Object {
                $line = $_.Line
                $parts = $line -split '\s+'
                $pid = $parts[-1]
                if ($pid -match '^\d+$') {
                    Write-Host "🔥 Killing process $pid on port $PortNumber" -ForegroundColor Yellow
                    taskkill /PID $pid /F | Out-Null
                }
            }
        } else {
            Write-Host "✅ Port $PortNumber is free" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Could not check port $PortNumber" -ForegroundColor Red
    }
}

# Function to kill Flutter/Dart processes
function Kill-FlutterProcesses {
    Write-Host "`n🧹 Cleaning up Flutter/Dart processes..." -ForegroundColor Yellow
    
    $flutterProcesses = @()
    try {
        $flutterProcesses += Get-Process -Name "dart*" -ErrorAction SilentlyContinue
        $flutterProcesses += Get-Process -Name "flutter*" -ErrorAction SilentlyContinue
    } catch {
        # Ignore errors finding processes
    }
    
    if ($flutterProcesses.Count -gt 0) {
        $flutterProcesses | ForEach-Object {
            Write-Host "🔥 Killing $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Yellow
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 2
    } else {
        Write-Host "✅ No Flutter/Dart processes found" -ForegroundColor Green
    }
}

# Main execution
Write-Host "`n1️⃣ Cleaning up processes..." -ForegroundColor Cyan

# Kill processes on common ports
$commonPorts = @(3000, 8080, 8081, 8082, 5000, 4000)
foreach ($port in $commonPorts) {
    Kill-ProcessOnPort -PortNumber $port
}

# Kill Flutter/Dart processes
Kill-FlutterProcesses

Write-Host "`n2️⃣ Checking project setup..." -ForegroundColor Cyan

# Verify we're in a Flutter project
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: No pubspec.yaml found. Make sure you're in a Flutter project directory." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter project detected" -ForegroundColor Green

# Check Flutter installation
try {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Host "✅ Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Flutter not found in PATH" -ForegroundColor Red
    exit 1
}

Write-Host "`n3️⃣ Launching Flutter Web..." -ForegroundColor Cyan
Write-Host "🌐 Target: http://localhost:$Port" -ForegroundColor Green
Write-Host "⏳ Please wait for compilation..." -ForegroundColor Yellow

# Construct Flutter command
$flutterCmd = "flutter run -d chrome --web-port $Port"
if ($Debug) {
    $flutterCmd += " --debug"
}

Write-Host "`n📡 Executing: $flutterCmd" -ForegroundColor Magenta
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Launch Flutter
try {
    Invoke-Expression $flutterCmd
} catch {
    Write-Host "`n❌ Error launching Flutter: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n🔧 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "  • Run 'flutter doctor' to check for issues" -ForegroundColor White
    Write-Host "  • Try 'flutter clean' and 'flutter pub get'" -ForegroundColor White
    Write-Host "  • Ensure Chrome is installed and accessible" -ForegroundColor White
    exit 1
}