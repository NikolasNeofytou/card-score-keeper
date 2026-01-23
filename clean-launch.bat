@echo off
echo 🧹 Starting clean Flutter launch...

echo 📱 Stopping existing processes...
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1

echo 🗑️  Cleaning Flutter cache...
call flutter clean >nul

echo 📦 Getting dependencies...
call flutter pub get >nul

echo 🚀 Launching with clean state...
call flutter run -d chrome --web-port 3000 --dart-define=DEVELOPMENT=true

pause