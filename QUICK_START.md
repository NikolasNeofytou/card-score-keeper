# Card Game Scorekeeper - Quick Reference

## Quick Commands

### PowerShell (Windows)
```powershell
# Development (web with hot-reload)
.\build-and-run.ps1 -Mode web

# Production build
.\build-and-run.ps1 -Mode web -Build

# Docker deployment
.\build-and-run.ps1 -Mode docker

# Mobile development
.\build-and-run.ps1 -Mode mobile
```

### Bash (Linux/Mac)
```bash
# Development (web with hot-reload)
./build-and-run.sh web

# Production build
./build-and-run.sh web --build

# Docker deployment
./build-and-run.sh docker

# Mobile development
./build-and-run.sh mobile
```

### Docker Commands
```bash
# Production deployment
docker-compose up -d
# Access: http://localhost:8080

# Development mode
docker-compose --profile dev up
# Access: http://localhost:5000

# Stop containers
docker-compose down

# View logs
docker-compose logs -f

# Rebuild
docker-compose up --build
```

## URLs
- **Local Development**: http://localhost:5000
- **Docker Production**: http://localhost:8080
- **Docker Development**: http://localhost:5000

## Common Tasks

### First Time Setup
```bash
# 1. Get dependencies
flutter pub get

# 2. Run development server
flutter run -d chrome
```

### Clean Build
```bash
# Clean build artifacts
flutter clean

# Get dependencies again
flutter pub get

# Run
flutter run -d chrome
```

### Production Build
```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## File Structure
```
lib/
├── app/              # App configuration and routing
├── domain/           # Business logic and models
├── data/             # Data persistence
├── state/            # State management (Riverpod)
└── ui/               # User interface
```

## Troubleshooting
- **Flutter not found**: Add Flutter to PATH or use Docker
- **Port in use**: Change port in commands or docker-compose.yml
- **Build fails**: Run with `--clean` flag or `flutter clean`
- **Dependencies error**: Delete `pubspec.lock` and run `flutter pub get`
