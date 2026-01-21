param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host "Tichu Development Helper Script" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\tichu-dev.ps1 [command]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Green
    Write-Host "  engine-deps      Get dependencies for tichu_engine"
    Write-Host "  engine-build     Generate JSON serialization code"
    Write-Host "  engine-test      Run tests for tichu_engine"
    Write-Host "  engine-all       Run deps, build, and test"
    Write-Host "  server-deps      Get dependencies for tichu_server"
    Write-Host "  server-run       Run tichu_server on port 8080"
    Write-Host "  server-dev       Run server with auto-reload"
    Write-Host "  help             Show this help"
    Write-Host ""
}

switch ($Command.ToLower()) {
    "engine-deps" {
        Write-Host "📦 Getting dependencies for tichu_engine..." -ForegroundColor Cyan
        docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart pub get
        Write-Host "✅ Dependencies installed" -ForegroundColor Green
    }
    
    "engine-build" {
        Write-Host "🔨 Generating JSON serialization code..." -ForegroundColor Cyan
        docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart run build_runner build --delete-conflicting-outputs
        Write-Host "✅ Code generated" -ForegroundColor Green
    }
    
    "engine-test" {
        Write-Host "🧪 Running tests for tichu_engine..." -ForegroundColor Cyan
        docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable sh -c "dart pub get && dart pub run test test/tichu_engine_test.dart"
    }
    
    "engine-all" {
        Write-Host "🚀 Running full engine setup..." -ForegroundColor Cyan
        & $PSCommandPath engine-deps
        & $PSCommandPath engine-build
        & $PSCommandPath engine-test
    }
    
    "server-deps" {
        Write-Host "📦 Getting dependencies for tichu_server..." -ForegroundColor Cyan
        docker run --rm -v ${PWD}/services/tichu_server:/app -v ${PWD}/packages:/packages -w /app dart:stable dart pub get
        Write-Host "✅ Dependencies installed" -ForegroundColor Green
    }
    
    "server-run" {
        Write-Host "🌐 Starting tichu_server on http://localhost:8081..." -ForegroundColor Cyan
        Write-Host "📡 WebSocket: ws://localhost:8081" -ForegroundColor Yellow
        Write-Host "🏥 Health: http://localhost:8081/health" -ForegroundColor Yellow
        Write-Host "(Server listens on port 8080 internally, mapped to 8081 on host)" -ForegroundColor Gray
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
        Write-Host ""
        docker run --rm -p 8081:8080 -v ${PWD}/services/tichu_server:/app -v ${PWD}/packages:/packages -w /app dart:stable sh -c "dart pub get && dart bin/server.dart"
    }
    
    "server-dev" {
        Write-Host "🔄 Starting tichu_server in dev mode..." -ForegroundColor Cyan
        Write-Host "Changes require restart (Ctrl+C and rerun)" -ForegroundColor Yellow
        Write-Host "Server on http://localhost:8081" -ForegroundColor Green
        Write-Host ""
        docker run --rm -it -p 8081:8080 -v ${PWD}/services/tichu_server:/app -v ${PWD}/packages:/packages -w /app dart:stable sh -c "dart pub get && dart bin/server.dart"
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
    }
}
