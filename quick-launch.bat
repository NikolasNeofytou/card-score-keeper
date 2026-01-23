@echo off
echo ================================
echo    Quick Flutter Launcher
echo ================================
echo.

REM Kill any processes on ports 3000, 8080, 8081
echo [1/3] Killing processes on busy ports...
netstat -ano | findstr ":3000" | findstr "LISTENING" > temp_ports.txt
netstat -ano | findstr ":8080" | findstr "LISTENING" >> temp_ports.txt  
netstat -ano | findstr ":8081" | findstr "LISTENING" >> temp_ports.txt

if exist temp_ports.txt (
    for /f "tokens=5" %%i in (temp_ports.txt) do (
        echo   Killing PID %%i
        taskkill /PID %%i /F >NUL 2>&1
    )
    del temp_ports.txt
)

REM Clean up any remaining Flutter processes
echo [2/3] Cleaning up Flutter/Dart processes...
taskkill /IM dart.exe /F >NUL 2>&1
taskkill /IM dartaotruntime.exe /F >NUL 2>&1
taskkill /IM dartvm.exe /F >NUL 2>&1

timeout /t 2 /nobreak >NUL

echo [3/3] Launching Flutter on http://localhost:3000
echo ================================================
echo.

REM Clean build and launch
flutter clean >NUL 2>&1
flutter pub get >NUL 2>&1
flutter run -d chrome --web-port 3000

echo.
echo Press any key to exit...
pause >NUL