# API Documentation

## State Management API

### Game Controller

#### Provider
```dart
final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) => GameController(ref.read(gameRepositoryProvider)),
);
```

#### Methods

##### `createGame(List<String> playerNames)`
Creates a new game with the specified players.

**Parameters:**
- `playerNames` (List<String>): List of player names (2-8 players)

**Returns:** `void`

**Side Effects:**
- Creates new Game instance
- Assigns player colors
- Saves to repository
- Updates state

**Example:**
```dart
ref.read(gameControllerProvider.notifier)
   .createGame(['Alice', 'Bob', 'Charlie']);
```

##### `addScores(Map<String, int> scores)`
Adds scores for the current round.

**Parameters:**
- `scores` (Map<String, int>): Player ID to score mapping

**Returns:** `void`

**Side Effects:**
- Creates new Round
- Updates player totals
- Records in undo history
- Saves to repository

**Example:**
```dart
ref.read(gameControllerProvider.notifier).addScores({
  'player-1-id': 15,
  'player-2-id': 8,
  'player-3-id': 12,
});
```

##### `recordPredictions(Map<String, int> predictions)`
Records player predictions for the current round.

**Parameters:**
- `predictions` (Map<String, int>): Player ID to prediction mapping

**Returns:** `void`

**Example:**
```dart
ref.read(gameControllerProvider.notifier).recordPredictions({
  'player-1-id': 10,
  'player-2-id': 15,
});
```

##### `endGame()`
Marks the current game as completed.

**Returns:** `void`

**Side Effects:**
- Updates game status
- Saves final state
- Archives game (optional)

##### `resetGame()`
Resets the current game to initial state.

**Returns:** `void`

**Warning:** This action cannot be undone.

---

### Game List Controller

#### Provider
```dart
final gameListControllerProvider = StateNotifierProvider<GameListController, GameListState>(
  (ref) => GameListController(ref.read(gameRepositoryProvider)),
);
```

#### Methods

##### `switchToGame(String gameId)`
Switches to a different game.

**Parameters:**
- `gameId` (String): UUID of the game to switch to

**Returns:** `Future<void>`

**Side Effects:**
- Saves current game
- Loads selected game
- Updates currentGameId
- Refreshes UI

**Example:**
```dart
await ref.read(gameListControllerProvider.notifier)
         .switchToGame('uuid-here');
```

##### `archiveGame(String gameId)`
Archives a game.

**Parameters:**
- `gameId` (String): UUID of the game to archive

**Returns:** `Future<void>`

**Side Effects:**
- Updates game status to archived
- Saves to repository
- Refreshes game list

##### `unarchiveGame(String gameId)`
Unarchives a previously archived game.

**Parameters:**
- `gameId` (String): UUID of the game to unarchive

**Returns:** `Future<void>`

##### `deleteGame(String gameId)`
Permanently deletes a game.

**Parameters:**
- `gameId` (String): UUID of the game to delete

**Returns:** `Future<void>`

**Warning:** This action cannot be undone.

**Example:**
```dart
await ref.read(gameListControllerProvider.notifier)
         .deleteGame('uuid-here');
```

##### `refreshGameList()`
Refreshes the game list from repository.

**Returns:** `Future<void>`

---

### Undo Controller

#### Provider
```dart
final undoControllerProvider = StateNotifierProvider<UndoController, UndoState>(
  (ref) => UndoController(),
);
```

#### Methods

##### `recordState(GameState gameState)`
Records a state snapshot for undo/redo.

**Parameters:**
- `gameState` (GameState): Current game state to record

**Returns:** `void`

**Side Effects:**
- Adds state to history buffer
- Trims old states if at max capacity (50)
- Clears redo history

**Example:**
```dart
final currentState = ref.read(gameControllerProvider);
ref.read(undoControllerProvider.notifier).recordState(currentState);
```

##### `undo()`
Undoes the last action.

**Returns:** `GameState?`

**Returns:** Previous game state or null if nothing to undo

**Example:**
```dart
final previousState = ref.read(undoControllerProvider.notifier).undo();
if (previousState != null) {
  // Apply previous state
}
```

##### `redo()`
Redoes the last undone action.

**Returns:** `GameState?`

**Returns:** Next game state or null if nothing to redo

##### `clear()`
Clears all undo/redo history.

**Returns:** `void`

---

### Theme Controller

#### Provider
```dart
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>(
  (ref) => ThemeController(),
);
```

#### Methods

##### `setThemeMode(ThemeMode mode)`
Sets the theme mode.

**Parameters:**
- `mode` (ThemeMode): Theme mode (light, dark, system)

**Returns:** `Future<void>`

**Side Effects:**
- Updates theme state
- Persists to SharedPreferences
- Triggers UI rebuild

**Example:**
```dart
await ref.read(themeControllerProvider.notifier)
         .setThemeMode(ThemeMode.dark);
```

##### `toggleTheme()`
Toggles between light and dark mode.

**Returns:** `Future<void>`

**Example:**
```dart
await ref.read(themeControllerProvider.notifier).toggleTheme();
```

##### `setUseSystemTheme(bool useSystem)`
Sets whether to follow system theme.

**Parameters:**
- `useSystem` (bool): Whether to use system theme

**Returns:** `Future<void>`

**Example:**
```dart
await ref.read(themeControllerProvider.notifier)
         .setUseSystemTheme(true);
```

---

## Repository API

### Game Repository Interface

```dart
abstract class GameRepository {
  Future<Game?> loadGame(String id);
  Future<void> saveGame(Game game);
  Future<void> deleteGame(String id);
  Future<List<GameInfo>> loadAllGames();
  Future<Game?> loadLastGame();
  Future<void> saveLastGame(Game game);
  Future<List<GameInfo>> loadGameList();
  Future<void> saveGameList(List<GameInfo> games);
}
```

#### Methods

##### `loadGame(String id)`
Loads a game by ID.

**Parameters:**
- `id` (String): Game UUID

**Returns:** `Future<Game?>` - Game instance or null if not found

##### `saveGame(Game game)`
Saves a game.

**Parameters:**
- `game` (Game): Game instance to save

**Returns:** `Future<void>`

**Side Effects:**
- Serializes to JSON
- Stores in Hive
- Updates game list metadata

##### `deleteGame(String id)`
Deletes a game.

**Parameters:**
- `id` (String): Game UUID

**Returns:** `Future<void>`

**Side Effects:**
- Removes from Hive storage
- Updates game list

##### `loadAllGames()`
Loads all games.

**Returns:** `Future<List<GameInfo>>` - List of game metadata

##### `loadGameList()`
Loads game list metadata.

**Returns:** `Future<List<GameInfo>>` - List of lightweight game info

##### `saveGameList(List<GameInfo> games)`
Saves game list metadata.

**Parameters:**
- `games` (List<GameInfo>): List of game metadata

**Returns:** `Future<void>`

---

## Data Models

### Game Model

```dart
class Game {
  final String id;
  final String name;
  final List<Player> players;
  final List<Round> rounds;
  final DateTime createdAt;
  final DateTime lastModified;
  final GameStatus status;
  
  Game({
    required this.id,
    required this.name,
    required this.players,
    this.rounds = const [],
    required this.createdAt,
    required this.lastModified,
    this.status = GameStatus.active,
  });
  
  // JSON serialization
  Map<String, dynamic> toJson();
  factory Game.fromJson(Map<String, dynamic> json);
}
```

#### Properties

- `id` (String): Unique UUID
- `name` (String): Game name/title
- `players` (List<Player>): List of players
- `rounds` (List<Round>): List of completed rounds
- `createdAt` (DateTime): Creation timestamp
- `lastModified` (DateTime): Last update timestamp
- `status` (GameStatus): Current status (active/completed/archived)

#### Methods

##### `copyWith({...})`
Creates a copy with modified fields.

**Example:**
```dart
final updatedGame = game.copyWith(
  name: 'New Name',
  lastModified: DateTime.now(),
);
```

---

### Player Model

```dart
class Player {
  final String id;
  final String name;
  final Color color;
  final int totalScore;
  final int totalPredictions;
  final int accuratePredictions;
  
  // Computed properties
  double get predictionAccuracy;
  double get averageScore;
}
```

#### Properties

- `id` (String): Player UUID
- `name` (String): Player display name
- `color` (Color): Assigned color
- `totalScore` (int): Cumulative score across all rounds
- `totalPredictions` (int): Number of predictions made
- `accuratePredictions` (int): Number of accurate predictions

#### Computed Properties

##### `predictionAccuracy`
Returns prediction accuracy as percentage (0.0 - 1.0).

##### `averageScore`
Returns average score per round.

---

### Round Model

```dart
class Round {
  final int number;
  final Map<String, int> predictions;
  final Map<String, int> scores;
  final DateTime timestamp;
  
  Round({
    required this.number,
    this.predictions = const {},
    required this.scores,
    required this.timestamp,
  });
}
```

#### Properties

- `number` (int): Round number (1-indexed)
- `predictions` (Map<String, int>): Player ID to prediction mapping
- `scores` (Map<String, int>): Player ID to score mapping
- `timestamp` (DateTime): When round was completed

---

### GameInfo Model

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

Lightweight version of Game for list views.

---

### Enums

#### GameStatus
```dart
enum GameStatus {
  active,     // Currently being played
  completed,  // Finished but not archived
  archived,   // Archived for reference
}
```

#### ThemeMode
```dart
enum ThemeMode {
  light,   // Light theme
  dark,    // Dark theme
  system,  // Follow system setting
}
```

---

## Navigation API

### Routes

All routes are defined in `lib/app/router.dart`.

#### Available Routes

| Route | Screen | Description |
|-------|--------|-------------|
| `/` | HomeScreen | Landing page |
| `/create` | CreateGameScreen | Create new game |
| `/scoreboard` | ScoreboardScreen | Current game scores |
| `/predictions` | PredictionsScreen | Enter predictions |
| `/results` | ResultsScreen | Round results |
| `/history` | HistoryScreen | Game history |
| `/games` | GameListScreen | Manage multiple games |
| `/settings` | SettingsScreen | App settings |

#### Navigation Examples

```dart
// Push route
context.push('/settings');

// Go to route (replaces current)
context.go('/scoreboard');

// Pop back
context.pop();

// Push with parameters (future)
context.push('/game/${gameId}');
```

---

## Theme API

### Color Palette

#### Light Theme (AppColors)

```dart
class AppColors {
  // Primary
  static const primary = Color(0xFF0969DA);        // Blue
  static const secondary = Color(0xFF1F883D);      // Green
  static const accent = Color(0xFFBF3989);         // Purple
  
  // Status
  static const success = Color(0xFF1F883D);
  static const warning = Color(0xFFFB8500);
  static const error = Color(0xFFCF222E);
  
  // Backgrounds
  static const background = Color(0xFFF6F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF6F8FA);
  
  // Text
  static const textPrimary = Color(0xFF24292F);
  static const textSecondary = Color(0xFF57606A);
  static const textTertiary = Color(0xFF6E7781);
  
  // Borders
  static const border = Color(0xFFD0D7DE);
  static const borderDark = Color(0xFF8C959F);
}
```

#### Dark Theme (AppColorsDark)

```dart
class AppColorsDark {
  static const primary = Color(0xFF58A6FF);
  static const secondary = Color(0xFF3FB950);
  // ... (see full definition in app_colors.dart)
}
```

### Usage

```dart
// Get current theme colors
final isDark = Theme.of(context).brightness == Brightness.dark;
final colors = isDark ? AppColorsDark : AppColors;

// Use colors
Container(
  color: colors.background,
  child: Text(
    'Hello',
    style: TextStyle(color: colors.textPrimary),
  ),
)
```

---

## Events & Callbacks

### Game Events

#### onGameCreated
Triggered when a new game is created.

#### onScoreAdded
Triggered when scores are added for a round.

#### onGameCompleted
Triggered when a game ends.

### Implementation

Currently uses Riverpod state changes. Future: Consider event bus pattern.

---

## Error Handling

### Repository Errors

```dart
try {
  await repository.saveGame(game);
} catch (e) {
  // Handle error
  print('Failed to save game: $e');
}
```

### State Errors

State includes optional error field:

```dart
class GameState {
  final String? error;
  // ...
}
```

Check for errors:

```dart
final gameState = ref.watch(gameControllerProvider);
if (gameState.error != null) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(gameState.error!)),
  );
}
```

---

## Testing API

### Mock Providers

```dart
// Override provider in tests
container = ProviderContainer(
  overrides: [
    gameRepositoryProvider.overrideWithValue(MockGameRepository()),
  ],
);
```

### Test Utilities

```dart
// Create test game
Game createTestGame({int playerCount = 3}) {
  return Game(
    id: 'test-id',
    name: 'Test Game',
    players: List.generate(
      playerCount,
      (i) => Player(id: 'p$i', name: 'Player $i'),
    ),
    createdAt: DateTime.now(),
    lastModified: DateTime.now(),
  );
}
```

---

## Performance Considerations

### State Updates

- Use `select` to listen to specific fields:
```dart
final playerCount = ref.watch(
  gameControllerProvider.select((state) => state.currentGame?.players.length),
);
```

### Repository Operations

- All repository methods are async
- Use `await` to ensure completion
- Consider loading states for UX

### Memory Management

- Undo history limited to 50 states
- Old game data auto-pruned (future)
- Dispose controllers properly

---

## Migration Guide

### Version 1.0 → 2.0 (Planned)

Breaking changes:
- Repository interface updates
- State structure changes
- New required fields

Migration steps:
1. Backup existing data
2. Run migration script
3. Update dependent code

---

## Changelog

### Version 1.0.0 (Current)
- Initial release
- Multiple game management
- Undo/redo system
- Dark mode support
- GitHub-inspired UI

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for API development guidelines.

## License

See [LICENSE](../LICENSE) for details.
