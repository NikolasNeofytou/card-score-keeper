# Quick Start for Windows (Without Flutter Installed)

## 🚀 Fastest Way - Use Docker

If you don't have Flutter installed, Docker is the easiest way:

### 1. Install Docker Desktop
Download from: https://www.docker.com/products/docker-desktop/

### 2. Start the App
```powershell
docker-compose up --build
```

### 3. Access the App
Open browser: http://localhost:8080

That's it! No Flutter installation needed.

---

## 🔧 Alternative: Install Flutter

If you want to develop locally:

### 1. Install Flutter
1. Download: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`

### 2. Verify Installation
```powershell
flutter doctor
```

### 3. Install Dependencies
```powershell
flutter pub get
```

### 4. Run the App
```powershell
flutter run -d chrome --web-port=5000
```

---

## 📋 Command Reference

### With Docker (No Flutter Required)
```powershell
# Start app
docker-compose up

# Stop app
docker-compose down

# View logs
docker-compose logs -f

# Rebuild
docker-compose up --build
```

### With Flutter Installed
```powershell
# Install dependencies
flutter pub get

# Run web app
flutter run -d chrome

# Build production
flutter build web --release
```

### Using PowerShell Script
```powershell
# Docker mode (no Flutter needed)
.\build-and-run.ps1 -Mode docker

# Web mode (requires Flutter)
.\build-and-run.ps1 -Mode web

# Mobile mode (requires Flutter + device)
.\build-and-run.ps1 -Mode mobile
```

---

## ❗ Troubleshooting

### "Flutter not found" Error
**Solution**: Use Docker mode OR install Flutter and add to PATH

### "Port already in use" Error
**Solution**: Stop other services on port 8080 or change port in docker-compose.yml

### Docker Build Fails
**Solution**: 
1. Make sure Docker Desktop is running
2. Check internet connection
3. Try: `docker system prune -a` then rebuild

### App Won't Start
**Solution**: 
1. Check Docker logs: `docker-compose logs`
2. Restart Docker Desktop
3. Rebuild: `docker-compose up --build`
