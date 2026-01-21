# Card Game Scorekeeper

A beautiful, feature-rich Flutter application for tracking scores in card games with predictions, statistics, and multiple game management. Inspired by GitHub's clean design aesthetic.

![GitHub-inspired UI](https://img.shields.io/badge/UI-GitHub_Inspired-0969DA?style=for-the-badge&logo=github)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=for-the-badge&logo=flutter)
![Riverpod](https://img.shields.io/badge/State-Riverpod-00A8E8?style=for-the-badge)
![Hive](https://img.shields.io/badge/Storage-Hive-FDB62F?style=for-the-badge)

##  Key Features

###  Game Management
- **Multiple Games**: Create and manage multiple games simultaneously
- **Game Switching**: Seamlessly switch between active games
- **Archive System**: Archive completed games for later reference
- **Persistent Storage**: Auto-saves using Hive database

###  Score Tracking
- **Round-Based Scoring**: Track scores for each round of play
- **Dynamic Player Count**: Support for 2-8 players per game
- **Real-Time Updates**: Live leaderboard with automatic calculations
- **Detailed History**: View complete round-by-round statistics

###  Predictions & Analytics
- **Pre-Round Predictions**: Players predict their scores before each round
- **Accuracy Tracking**: Monitor prediction accuracy over time
- **Performance Metrics**: Win rates, averages, and trends
- **Visual Statistics**: Charts and graphs using fl_chart

###  Modern UI
- **GitHub-Inspired Design**: Clean, professional aesthetic
- **Dark Mode**: Eye-friendly dark theme with GitHub's dark palette
- **Light Mode**: Crisp, readable light theme
- **Smooth Animations**: Polished transitions with flutter_animate
- **Confetti Celebrations**: Celebrate winners with confetti effects

###  Advanced Features
- **Undo/Redo**: 50-state history for correcting mistakes
- **Theme Switching**: Toggle between light/dark modes
- **System Theme**: Automatically follow device theme preferences
- **Responsive Design**: Works on mobile, tablet, and web

## 📱 Screenshots

| Home Screen | Scoreboard | Dark Mode |
|-------------|------------|-----------|
| ![Home](docs/screenshots/home.png) | ![Scoreboard](docs/screenshots/scoreboard.png) | ![Dark](docs/screenshots/dark.png) |

##  Quick Start

### Prerequisites

- **Flutter SDK** (3.0.0 or higher) - for local development
- **Docker** (optional) - for containerized deployment
- **Dart SDK** - included with Flutter

### Quick Start Options

#### Option 1: Using Makefile (Simplest)

If you have `make` installed:
```bash
# First time setup
make install

# Run web app
make run

# Build and deploy with Docker
make docker-up

# View all commands
make help
```

#### Option 2: Using Build Scripts

**Windows (PowerShell):**
```powershell
# Run web version
.\build-and-run.ps1 -Mode web

# Build production web version
.\scripts\build-and-run.ps1 -Mode web -Build

# Run mobile version
.\scripts\build-and-run.ps1 -Mode mobile

# Run with Docker
.\scripts\build-and-run.ps1 -Mode docker

# Clean and rebuild
.\scripts\build-and-run.ps1 -Mode web -Clean
```

**Linux/Mac (Bash):**
```bash
# Make script executable
chmod +x scripts/build-and-run.sh

# Run web version
./build-and-run.sh web

# Build production web version
./scripts/build-and-run.sh web --build

# Run mobile version
./scripts/build-and-run.sh mobile

# Run with Docker
./build-and-run.sh docker

# Clean and rebuild
./build-and-run.sh web --clean
```

#### Option 2: Docker (Run Anywhere)

**Production build:**
```bash
# Build and run with docker-compose
docker-compose up --build

# Access at http://localhost:8080
```

**Development mode:**
```bash
# Run development server with hot-reload
docker-compose --profile dev up card-scorekeeper-dev

# Access at http://localhost:5000
```

**Using Docker directly:**
```bash
# Build image
docker build -t card-scorekeeper .

# Run container
docker run -d -p 8080:80 card-scorekeeper

# Access at http://localhost:8080
```

#### Option 3: Manual Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome --web-port=5000

# Run on mobile device
flutter run

# Build for production
flutter build web --release
flutter build apk --release  # Android
flutter build ios --release  # iOS (requires macOS)
```

## 📁 Project Structure

```
card-score-keeper/
├── deployment/          # Docker and deployment configuration
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── nginx.conf
│   └── .dockerignore
├── docs/               # Documentation files
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── QUICK_START.md
│   └── ...
├── lib/                # Main Flutter application
│   ├── app/            # App configuration and routing
│   ├── data/           # Data layer (repositories, storage)
│   ├── domain/         # Business logic and models
│   ├── state/          # State management (Riverpod)
│   └── ui/             # User interface (screens, widgets)
├── packages/           # Custom packages (monorepo)
│   ├── tichu_engine/   # Tichu game logic
│   └── tichu_server/   # WebSocket server
├── scripts/            # Build and development scripts
│   ├── build-and-run.ps1
│   ├── build-and-run.sh
│   └── tichu-dev.ps1
├── test/               # Tests for main app
│   ├── unit/           # Unit tests
│   ├── integration/    # Integration tests
│   └── widget_test.dart
└── pubspec.yaml        # Flutter dependencies
```

## Usage

1. **Create Game**: Add players and configure peak cards (2-13) and bonus points (0-20)
2. **Start Round**: Enter predictions for each player
3. **End Round**: Enter actual wins (must equal cards in round)
4. **View Leaderboard**: See live rankings after each round
5. **History**: Review completed rounds
6. **Undo**: Remove the last completed round if needed

## Deployment Options

### Web Deployment
The app can be deployed as a web application to any static hosting service:

- **GitHub Pages**: `flutter build web && gh-pages -d build/web`
- **Netlify**: Deploy `build/web` folder
- **Firebase Hosting**: `firebase deploy`
- **Docker/Kubernetes**: Use included Dockerfile and docker-compose.yml

### Mobile Deployment
- **Android**: Build APK/AAB for Google Play Store
- **iOS**: Build IPA for Apple App Store (requires macOS)

### Container Registry
```bash
# Tag and push to registry
docker tag card-scorekeeper your-registry/card-scorekeeper:latest
docker push your-registry/card-scorekeeper:latest
```

## Configuration

### Environment Variables (Docker)
- `NGINX_HOST`: Host configuration (default: localhost)
- `NGINX_PORT`: Port configuration (default: 80)

### Build Configuration
Edit [pubspec.yaml](pubspec.yaml) to modify:
- App name and version
- Dependencies
- Flutter SDK constraints

## Architecture

### Tech Stack
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Navigation**: go_router
- **Persistence**: Hive (local storage)
- **Web Server**: Nginx (Docker)

## Dependencies

- `flutter_riverpod`: State management
- `go_router`: Navigation
- `hive` & `hive_flutter`: Local persistence
- `uuid`: Unique ID generation

## Acceptance Criteria

 Create game with players and peakCards=7 generates schedule [1,2,3,4,5,6,7,6,5,4,3,2,1]  
 Each round: save predictions, then save results only when sum(actualWins)=cardsThisRound  
 Leaderboard updates after each round  
 Undo last completed round works  
App resumes last game after restart

## Troubleshooting

### Flutter not found
Install Flutter SDK from https://flutter.dev/docs/get-started/install

### Docker build fails
Ensure Docker is running and you have internet connection for pulling base images

### Port already in use
Change ports in docker-compose.yml or use different ports in run commands

### Web app not loading
Clear browser cache and ensure all dependencies are installed

## License

MIT License
