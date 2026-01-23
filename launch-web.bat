@echo off
REM Simple Flutter Web Launcher
REM Kills existing processes and launches on port 3000

echo ===============================
echo    Flutter Web Launcher
echo ===============================

REM Kill processes on common ports
echo Cleaning up ports...
for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":3000 " ^| findstr "LISTENING"') do (
    echo Killing process %%i on port 3000
    taskkill /PID %%i /F >NUL 2>&1
)

for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":8080 " ^| findstr "LISTENING"') do (
    echo Killing process %%i on port 8080  
    taskkill /PID %%i /F >NUL 2>&1
)

for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":8081 " ^| findstr "LISTENING"') do (
    echo Killing process %%i on port 8081
    taskkill /PID %%i /F >NUL 2>&1
)

REM Kill Flutter/Dart processes
echo Cleaning up Flutter processes...
taskkill /IM dart.exe /F >NUL 2>&1
taskkill /IM dartaotruntime.exe /F >NUL 2>&1  
taskkill /IM dartvm.exe /F >NUL 2>&1

echo.
echo Starting Flutter Web on http://localhost:3000
echo ===============================

REM Launch Flutter
flutter run -d chrome --web-port 3000

pause