# 📁 Complete Project Structure

```
card-score-keeper/
│
├── 📄 Configuration Files
│   ├── pubspec.yaml              # Flutter dependencies & app metadata
│   ├── analysis_options.yaml     # Dart/Flutter linting rules
│   ├── .gitignore                # Git ignore patterns
│   ├── .dockerignore             # Docker ignore patterns
│   └── nginx.conf                # Nginx web server configuration
│
├── 🐳 Docker Files
│   ├── Dockerfile                # Multi-stage Docker build
│   └── docker-compose.yml        # Docker Compose configuration
│
├── 🔧 Build & Run Scripts
│   ├── Makefile                  # Cross-platform make commands
│   ├── build-and-run.ps1         # PowerShell script (Windows)
│   └── build-and-run.sh          # Bash script (Linux/Mac)
│
├── 📚 Documentation
│   ├── README.md                 # Main project documentation
│   ├── QUICK_START.md            # Quick reference guide
│   └── DEPLOYMENT.md             # Comprehensive deployment guide
│
└── 📱 Application Code (lib/)
    │
    ├── main.dart                 # Application entry point
    │
    ├── 🎨 app/
    │   ├── app.dart              # Main app widget with theme & routing
    │   └── router.dart           # Go router configuration & routes
    │
    ├── 🏢 domain/                # Business Logic Layer
    │   ├── models/
    │   │   ├── game.dart         # Game, GameSettings, GameState
    │   │   ├── player.dart       # Player model
    │   │   └── round.dart        # GameRound, RoundEntry, RoundStatus
    │   │
    │   └── logic/
    │       ├── schedule.dart     # Round schedule generation
    │       ├── scoring.dart      # Points calculation logic
    │       └── validation.dart   # Results validation logic
    │
    ├── 💾 data/                  # Data Layer
    │   ├── game_repository.dart      # Repository interface
    │   └── hive_game_repository.dart # Hive implementation
    │
    ├── 🔄 state/                 # State Management (Riverpod)
    │   ├── game_state.dart       # State model & derived getters
    │   └── game_controller.dart  # State notifier & business logic
    │
    └── 🎨 ui/                    # User Interface Layer
        │
        ├── screens/
        │   ├── home_screen.dart          # Landing page (resume/new game)
        │   ├── create_game_screen.dart   # Game creation form
        │   ├── scoreboard_screen.dart    # Live leaderboard & round info
        │   ├── predictions_screen.dart   # Enter predictions phase
        │   ├── results_screen.dart       # Enter results phase
        │   └── history_screen.dart       # Completed rounds history
        │
        └── widgets/
            ├── number_stepper.dart       # Increment/decrement input
            ├── leaderboard_table.dart    # Rankings table
            └── player_round_row.dart     # Player input row
```

## 📊 File Statistics

### Code Organization
- **Total Screens**: 6 (Home, Create, Scoreboard, Predictions, Results, History)
- **Reusable Widgets**: 3 (NumberStepper, LeaderboardTable, PlayerRoundRow)
- **Domain Models**: 3 (Game, Player, Round)
- **Domain Logic**: 3 (Schedule, Scoring, Validation)
- **State Management**: 2 files (State & Controller)
- **Data Persistence**: 2 files (Interface & Implementation)

### Infrastructure
- **Build Scripts**: 3 (Makefile, PowerShell, Bash)
- **Docker Files**: 2 (Dockerfile, docker-compose.yml)
- **Config Files**: 4 (pubspec, analysis_options, nginx, dockerignore)
- **Documentation**: 3 (README, QUICK_START, DEPLOYMENT)

## 🔗 Architecture Flow

```
User Interaction (UI Screens)
        ↓
State Management (Riverpod Controller)
        ↓
Business Logic (Domain Layer)
        ↓
Data Persistence (Hive Repository)
        ↓
Local Storage (Hive Database)
```

## 🎯 Key Files by Purpose

### 🚀 **Getting Started**
- `QUICK_START.md` - Quick commands & reference
- `README.md` - Full documentation
- `Makefile` - Simplest commands

### 🛠️ **Development**
- `lib/main.dart` - App entry point
- `lib/state/game_controller.dart` - Core business logic
- `build-and-run.ps1` or `.sh` - Build & run scripts

### 🐳 **Deployment**
- `Dockerfile` - Container image definition
- `docker-compose.yml` - Orchestration config
- `DEPLOYMENT.md` - Deployment guide

### 📝 **Business Logic**
- `lib/domain/logic/schedule.dart` - Round schedule [1..P..1]
- `lib/domain/logic/scoring.dart` - Points calculation
- `lib/domain/logic/validation.dart` - Results validation

### 🎨 **User Interface**
- `lib/ui/screens/scoreboard_screen.dart` - Main game screen
- `lib/ui/screens/predictions_screen.dart` - Predictions input
- `lib/ui/screens/results_screen.dart` - Results input with validation

## 🔄 Data Flow Example

**Creating a New Game:**
```
1. User fills form (create_game_screen.dart)
2. Controller.createGame() (game_controller.dart)
3. Generate schedule (schedule.dart)
4. Create Game model (game.dart)
5. Save to Hive (hive_game_repository.dart)
6. Update state (game_state.dart)
7. Navigate to scoreboard (router.dart)
```

**Completing a Round:**
```
1. Start Round → predictions_screen.dart
2. Save predictions → game_controller.savePredictions()
3. End Round → results_screen.dart
4. Validate sum(actualWins) == cardsThisRound (validation.dart)
5. Calculate points for each player (scoring.dart)
6. Update game state → game_controller.saveResults()
7. Persist to storage (hive_game_repository.dart)
8. Update leaderboard display (scoreboard_screen.dart)
```

## 🎨 UI Navigation Flow

```
Home Screen
    ↓
    ├─→ Resume Game → Scoreboard Screen
    │                      ↓
    │                      ├─→ Start Round → Predictions Screen
    │                      │                      ↓
    │                      │                Save Predictions
    │                      │                      ↓
    │                      ├─→ End Round → Results Screen
    │                      │                      ↓
    │                      │                Save Results (validated)
    │                      │                      ↓
    │                      │                Back to Scoreboard
    │                      │
    │                      └─→ View History → History Screen
    │                                             ↓
    │                                        Undo Last Round
    │                                             ↓
    │                                        Back to Scoreboard
    │
    └─→ New Game → Create Game Screen
                        ↓
                   Setup Complete
                        ↓
                   Scoreboard Screen
```

## 💡 Quick Command Reference

| Task | Command |
|------|---------|
| Install dependencies | `make install` |
| Run development | `make run` |
| Build production | `make build` |
| Deploy with Docker | `make docker-up` |
| Run tests | `make test` |
| Format code | `make format` |
| View all commands | `make help` |

## 🔐 Environment & State

**Persistent Data (Hive):**
- Last game state
- All rounds & scores
- Player information

**Runtime State (Riverpod):**
- Current game
- Leaderboard calculations
- UI state & validation

**No Backend Required:**
- All data stored locally
- No API calls
- Offline-first design
