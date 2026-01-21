# Architecture Documentation

## Overview
This document describes the architecture and design decisions for the Card Game Scorekeeper application.

## Architecture Pattern

### Clean Architecture Approach
The application follows a modified Clean Architecture pattern with clear separation of concerns:

```
lib/
├── app/                    # Application configuration
│   ├── app.dart           # Main app widget with theme support
│   └── router.dart        # Route definitions
├── domain/                 # Business logic (models, entities)
│   ├── models/            # Data models
│   └── repositories/      # Repository interfaces
├── data/                   # Data layer
│   └── repositories/      # Repository implementations
├── state/                  # State management
│   ├── *_state.dart       # State classes
│   ├── *_controller.dart  # State controllers
│   └── providers.dart     # Provider definitions
└── ui/                     # Presentation layer
    ├── screens/           # Full-screen views
    ├── widgets/           # Reusable components
    └── theme/             # Theme configuration
```

## State Management

### Riverpod Architecture

#### Providers
The app uses Riverpod's provider pattern for dependency injection and state management:

```dart
// State Provider
final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) => GameController(ref.read(gameRepositoryProvider)),
);

// Repository Provider
final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => HiveGameRepository(),
);
```

#### State Classes
Each feature has a dedicated state class:

**GameState** - Core game state
```dart
class GameState {
  final Game? currentGame;
  final List<Round> rounds;
  final bool isLoading;
  final String? error;
}
```

**GameListState** - Multiple game management
```dart
class GameListState {
  final List<GameInfo> games;
  final String? currentGameId;
}
```

**UndoState** - Undo/redo history
```dart
class UndoState {
  final List<GameState> history;
  final int currentIndex;
  final int maxHistorySize;
}
```

**ThemeState** - Theme preferences
```dart
class ThemeState {
  final ThemeMode mode;
  final bool useSystemTheme;
}
```

#### Controllers
Controllers manage state mutations and business logic:

**GameController**
- Manages current game state
- Handles player operations
- Processes score updates
- Coordinates with repository

**GameListController**
- Manages multiple games
- Handles game switching
- Archives/unarchives games
- Deletes games

**UndoController**
- Records state snapshots
- Performs undo operations
- Performs redo operations
- Manages history buffer

**ThemeController**
- Switches themes
- Persists preferences
- Handles system theme

## Data Layer

### Repository Pattern

#### Abstract Repository
```dart
abstract class GameRepository {
  Future<Game?> loadGame(String id);
  Future<void> saveGame(Game game);
  Future<void> deleteGame(String id);
  Future<List<GameInfo>> loadAllGames();
  Future<List<GameInfo>> loadGameList();
  Future<void> saveGameList(List<GameInfo> games);
}
```

#### Hive Implementation
```dart
class HiveGameRepository implements GameRepository {
  // Keys for Hive storage
  static const _keyLastGame = 'last_game_json';
  static const _keyGameList = 'game_list_json';
  static const _keyGamesPrefix = 'game_';
  
  // Implementation using Hive box
}
```

### Data Storage

#### Hive Database
- **Type**: NoSQL key-value store
- **Format**: JSON serialization
- **Location**: Local device storage
- **Encryption**: Not yet implemented (planned)

#### Storage Keys
- `last_game_json`: Last played game (backward compatibility)
- `game_list_json`: List of all games metadata
- `game_{uuid}`: Individual game data

#### SharedPreferences
Used for app settings and preferences:
- `theme_mode`: Selected theme (light/dark)
- `use_system_theme`: Whether to follow system theme

### Data Models

#### Game Model
```dart
class Game {
  final String id;
  final String name;
  final List<Player> players;
  final List<Round> rounds;
  final DateTime createdAt;
  final DateTime lastModified;
  final GameStatus status;
}
```

#### Player Model
```dart
class Player {
  final String id;
  final String name;
  final Color color;
  final int totalScore;
  final int totalPredictions;
  final int accuratePredictions;
}
```

#### Round Model
```dart
class Round {
  final int number;
  final Map<String, int> predictions;
  final Map<String, int> scores;
  final DateTime timestamp;
}
```

#### GameInfo Model (Lightweight)
```dart
class GameInfo {
  final String id;
  final String name;
  final int playerCount;
  final DateTime createdAt;
  final DateTime lastModified;
  final GameStatus status;
}
```

## UI Layer

### Screen Architecture

#### Screen Types
1. **Full Screens**: Complete pages with app bar
   - HomeScreen
   - CreateGameScreen
   - ScoreboardScreen
   - GameListScreen
   - SettingsScreen

2. **Modal Screens**: Overlays and dialogs
   - PredictionsScreen
   - ResultsScreen

3. **History Screens**: Data visualization
   - HistoryScreen

#### Navigation Flow
```
HomeScreen
├── /create → CreateGameScreen
├── /scoreboard → ScoreboardScreen
│   ├── /predictions → PredictionsScreen
│   └── /results → ResultsScreen
├── /games → GameListScreen
├── /settings → SettingsScreen
└── /history → HistoryScreen
```

### Theme System

#### Color Palette
Organized into semantic color classes:

**AppColors** (Light Theme)
```dart
class AppColors {
  // Primary colors
  static const primary = Color(0xFF0969DA);
  static const secondary = Color(0xFF1F883D);
  
  // Background colors
  static const background = Color(0xFFF6F8FA);
  static const surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const textPrimary = Color(0xFF24292F);
  static const textSecondary = Color(0xFF57606A);
  
  // Player colors (10 variants)
  static const playerColors = [...];
}
```

**AppColorsDark** (Dark Theme)
```dart
class AppColorsDark {
  // Adjusted for dark mode
  static const primary = Color(0xFF58A6FF);
  static const background = Color(0xFF0D1117);
  // ... etc
}
```

#### Theme Configuration
```dart
class AppTheme {
  static ThemeData get lightTheme { ... }
  static ThemeData get darkTheme { ... }
}
```

### Widget Composition

#### Reusable Widgets
- **PlayerCard**: Display player info
- **ScoreInput**: Number input component
- **StatCard**: Statistics display
- **RoundHeader**: Round information
- **GameCard**: Game list item

#### Animation Strategy
- **flutter_animate**: Declarative animations
- **Implicit Animations**: Built-in Flutter animations
- **Custom Transitions**: Route transitions

## Feature Implementation

### Multiple Game Management

#### Architecture
```
GameListScreen
    ↓
GameListController
    ↓
GameRepository
    ↓
Hive Storage
```

#### Workflow
1. User creates/selects game
2. Controller updates current game ID
3. UI reloads with new game data
4. Old game auto-saved

### Undo/Redo System

#### Implementation
```dart
class UndoController extends StateNotifier<UndoState> {
  void recordState(GameState gameState) {
    // Trim history if at limit
    // Add new state to history
    // Update current index
  }
  
  void undo() {
    // Move back in history
    // Restore previous state
  }
  
  void redo() {
    // Move forward in history
    // Restore next state
  }
}
```

#### State Snapshot
- Captures full game state
- Stores in circular buffer
- Max 50 states
- Oldest states discarded

### Theme Switching

#### Theme Provider
```dart
final themeProvider = StateNotifierProvider<ThemeController, ThemeState>(
  (ref) => ThemeController(),
);
```

#### Persistence
```dart
// Save preference
await prefs.setString('theme_mode', 'dark');

// Load preference
final savedMode = prefs.getString('theme_mode');
```

## Performance Optimizations

### State Updates
- **Selective Rebuilds**: Only affected widgets rebuild
- **Computed Properties**: Memoized calculations
- **Lazy Loading**: Load games on demand

### Data Operations
- **Async Loading**: Non-blocking UI
- **Batch Updates**: Group multiple changes
- **Debouncing**: Delay rapid updates

### Memory Management
- **Dispose Controllers**: Clean up on navigation
- **Weak References**: Prevent memory leaks
- **Image Caching**: Reuse loaded assets

## Testing Strategy

### Unit Tests
- State logic
- Business rules
- Data transformations

### Widget Tests
- UI components
- User interactions
- Visual regression

### Integration Tests
- End-to-end flows
- Navigation
- Data persistence

## Security Considerations

### Current
- Local data only
- No network requests
- No sensitive data

### Planned
- Encryption at rest
- Secure cloud sync
- Authentication
- Data export encryption

## Build & Deployment

### Development
```bash
flutter run -d web
flutter run -d chrome
```

### Production Build
```bash
flutter build web --release
flutter build apk --release
flutter build ios --release
```

### Docker Deployment
```dockerfile
FROM ghcr.io/cirruslabs/flutter:stable
# ... build steps
EXPOSE 8080
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080"]
```

## Dependencies

### Core
- `flutter_riverpod: ^2.4.9` - State management
- `go_router: ^13.0.0` - Navigation
- `hive: ^2.2.3` - Database
- `uuid: ^4.2.2` - ID generation

### UI
- `google_fonts: ^6.1.0` - Typography
- `flutter_animate: ^4.5.0` - Animations


### Utilities
- `shared_preferences: ^2.2.2` - Preferences
- `intl: ^0.18.1` - Internationalization

## Future Improvements

### Architecture
- Migrate to BLoC pattern (consideration)
- Add use cases layer
- Implement event sourcing
- Add domain events

### Performance
- Implement pagination
- Add caching layer
- Optimize rebuild strategy
- Profile and optimize

### Testing
- Increase coverage to 80%+
- Add integration tests
- Add E2E tests
- Automated UI testing

### Features
- Offline-first architecture
- Conflict resolution
- Data migration tools
- Plugin system
