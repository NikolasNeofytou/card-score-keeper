# Deployment & Build Guide

## Complete Setup Options

### 🎯 Recommended Quick Start

**With Make (Cross-platform):**
```bash
make install    # Install dependencies
make run        # Start development server
```

**With Docker (Zero dependencies):**
```bash
docker-compose up --build
# Visit http://localhost:8080
```

---

## 📋 All Available Methods

### 1️⃣ Makefile Commands (Recommended)

The Makefile provides the simplest interface for all operations:

```bash
# Setup
make install        # Install Flutter dependencies
make clean          # Clean build artifacts
make setup          # Clean + Install

# Development
make run            # Run web app (default)
make run-web        # Run web with hot-reload
make run-mobile     # Run on connected device
make dev            # Install + Run web

# Production Build
make build          # Build web app
make build-web      # Build web app
make build-mobile   # Build Android APK

# Docker Operations
make docker-build   # Build Docker image
make docker-run     # Run Docker container
make docker-up      # Start with compose (production)
make docker-down    # Stop compose
make docker-logs    # View logs
make docker-dev     # Development mode with hot-reload

# Quality & Testing
make test           # Run tests
make format         # Format code
make lint           # Analyze code

# Combined Operations
make rebuild        # Clean + Install + Build
make deploy         # Full deployment pipeline
make prod           # Build + Docker deploy
```

---

### 2️⃣ Build Scripts

**Windows (PowerShell):**
```powershell
# Web Development
.\build-and-run.ps1 -Mode web

# Web Production Build
.\build-and-run.ps1 -Mode web -Build

# Mobile Development
.\build-and-run.ps1 -Mode mobile

# Docker Deployment
.\build-and-run.ps1 -Mode docker

# Clean Build
.\build-and-run.ps1 -Mode web -Clean
```

**Linux/Mac (Bash):**
```bash
# Make executable first
chmod +x build-and-run.sh

# Web Development
./build-and-run.sh web

# Web Production Build
./build-and-run.sh web --build

# Mobile Development
./build-and-run.sh mobile

# Docker Deployment
./build-and-run.sh docker

# Clean Build
./build-and-run.sh web --clean
```

---

### 3️⃣ Docker Commands

**Production Deployment:**
```bash
# Using docker-compose (recommended)
docker-compose up -d --build
# App: http://localhost:8080

# Using Docker directly
docker build -t card-scorekeeper .
docker run -d -p 8080:80 card-scorekeeper
# App: http://localhost:8080
```

**Development Mode:**
```bash
# Hot-reload development server
docker-compose --profile dev up
# App: http://localhost:5000
```

**Management:**
```bash
# Stop containers
docker-compose down

# View logs
docker-compose logs -f card-scorekeeper

# Restart
docker-compose restart

# Rebuild
docker-compose up --build

# Clean everything
docker-compose down -v
```

---

### 4️⃣ Native Flutter Commands

**Setup:**
```bash
# Install dependencies
flutter pub get

# Check Flutter installation
flutter doctor
```

**Development:**
```bash
# Web (Chrome)
flutter run -d chrome --web-port=5000

# Web (Edge)
flutter run -d edge

# Mobile (connected device)
flutter run

# Specific device
flutter devices
flutter run -d <device-id>
```

**Production Builds:**
```bash
# Web
flutter build web --release
# Output: build/web/

# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/

# Android App Bundle
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/

# iOS (macOS only)
flutter build ios --release
```

**Maintenance:**
```bash
# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

---

## 🚀 Deployment Scenarios

### Local Development (Hot Reload)
```bash
# Fastest iteration
make run
# or
flutter run -d chrome
```

### Testing Production Build Locally
```bash
# Build and serve
make build
cd build/web
python -m http.server 8000
# Visit: http://localhost:8000
```

### Docker Local Deployment
```bash
# Production-like environment
make docker-up
# Visit: http://localhost:8080
```

### Cloud Deployment

**Static Hosting (Netlify, Vercel, Firebase):**
```bash
# Build
flutter build web --release

# Deploy build/web folder to your provider
```

**Container Registry (AWS ECR, Docker Hub, GCR):**
```bash
# Build and tag
docker build -t your-registry/card-scorekeeper:latest .

# Push
docker push your-registry/card-scorekeeper:latest

# Deploy to cloud provider
# (AWS ECS, Google Cloud Run, Azure Container Instances, etc.)
```

**Kubernetes:**
```bash
# Build and push image
docker build -t your-registry/card-scorekeeper:latest .
docker push your-registry/card-scorekeeper:latest

# Apply Kubernetes manifests (create your own deployment.yaml)
kubectl apply -f deployment.yaml
```

---

## 🔧 Configuration

### Environment Variables
Set in docker-compose.yml or at runtime:
- `NGINX_HOST`: Host configuration (default: localhost)
- `NGINX_PORT`: Port configuration (default: 80)

### Port Configuration
- **Development Web**: 5000 (configurable)
- **Docker Production**: 8080 → 80 (configurable in docker-compose.yml)
- **Docker Development**: 5000 → 5000

Change ports in docker-compose.yml:
```yaml
ports:
  - "YOUR_PORT:80"  # Change YOUR_PORT
```

### Build Configuration
Edit pubspec.yaml:
- App name and version
- Dependencies
- SDK constraints

---

## 🐛 Troubleshooting

### Flutter Not Found
```bash
# Check installation
flutter doctor

# Install from: https://flutter.dev/docs/get-started/install
# Add to PATH
```

### Docker Issues
```bash
# Check Docker is running
docker ps

# Restart Docker daemon
# Windows: Restart Docker Desktop
# Linux: sudo systemctl restart docker

# Clean Docker cache
docker system prune -a
```

### Port Already in Use
```bash
# Find process using port
# Windows: netstat -ano | findstr :8080
# Linux/Mac: lsof -i :8080

# Kill process or change port in docker-compose.yml
```

### Build Failures
```bash
# Full clean build
make clean
make install
make build

# Or with Flutter
flutter clean
rm pubspec.lock
flutter pub get
flutter build web
```

### Dependencies Issues
```bash
# Delete lock file and reinstall
rm pubspec.lock
flutter pub get

# Upgrade all packages
flutter pub upgrade
```

---

## 📊 Performance Tips

### Web Build Optimization
```bash
# Build with optimizations
flutter build web --release --web-renderer canvaskit

# Or with auto renderer
flutter build web --release --web-renderer auto
```

### Docker Image Size
The multi-stage Dockerfile already optimizes size:
- Stage 1: Build with Flutter SDK (~2GB)
- Stage 2: Serve with Nginx Alpine (~50MB final image)

### Caching
- Nginx configuration includes aggressive caching for assets
- Service worker for offline support (Flutter default)

---

## 📝 Additional Resources

- **Main README**: [README.md](README.md)
- **Quick Start**: [QUICK_START.md](QUICK_START.md)
- **Flutter Docs**: https://flutter.dev/docs
- **Docker Docs**: https://docs.docker.com/
- **Riverpod Docs**: https://riverpod.dev/

---

## 🎯 Common Workflows

**Daily Development:**
```bash
make run
# Edit code, save, see changes instantly
```

**Before Commit:**
```bash
make format
make lint
make test
```

**Local Testing:**
```bash
make build
# Test build/web/ locally
```

**Deployment:**
```bash
make deploy
# Builds and deploys with Docker
```

**Clean Start:**
```bash
make clean
make install
make run
```
