# Architecture Visualization

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ HomeScreen   │  │ GameListScr  │  │ SettingsScreen      │  │
│  │              │  │              │  │                     │  │
│  │ - Resume     │  │ - Active     │  │ - Theme Toggle     │  │
│  │ - New Game   │  │ - Archived   │  │ - System Theme     │  │
│  │ - History    │  │ - Switch     │  │ - About            │  │
│  └──────────────┘  └──────────────┘  └─────────────────────┘  │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ Scoreboard   │  │ Predictions  │  │ Results             │  │
│  │              │  │              │  │                     │  │
│  │ - Scores     │  │ - Enter      │  │ - Accuracy         │  │
│  │ - Rankings   │  │ - Track      │  │ - Statistics       │  │
│  │ - Add Round  │  │ - Validate   │  │ - Charts           │  │
│  └──────────────┘  └──────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      State Management Layer                      │
│                         (Riverpod)                               │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ GameController   │  │ GameListControl  │  │ UndoControl  │ │
│  │                  │  │                  │  │              │ │
│  │ - Create Game    │  │ - Switch Game    │  │ - Record     │ │
│  │ - Add Scores     │  │ - Archive Game   │  │ - Undo       │ │
│  │ - Predictions    │  │ - Delete Game    │  │ - Redo       │ │
│  │ - End Game       │  │ - Refresh List   │  │ - Clear      │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
│                                                                  │
│  ┌──────────────────┐                                           │
│  │ ThemeController  │                                           │
│  │                  │                                           │
│  │ - Set Theme      │                                           │
│  │ - Toggle Theme   │                                           │
│  │ - System Theme   │                                           │
│  └──────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       State Classes Layer                        │
│                        (Immutable)                               │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  ┌──────────┐ │
│  │ GameState   │  │ GameList    │  │ UndoState│  │ Theme    │ │
│  │             │  │ State       │  │          │  │ State    │ │
│  │ - Current   │  │             │  │ - History│  │          │ │
│  │   Game      │  │ - Games[]   │  │ - Index  │  │ - Mode   │ │
│  │ - Rounds    │  │ - CurrentId │  │ - Max    │  │ - System │ │
│  │ - Loading   │  │             │  │          │  │          │ │
│  │ - Error     │  │             │  │          │  │          │ │
│  └─────────────┘  └─────────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Repository Interface                        │
│                        (Abstract)                                │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ GameRepository                                          │   │
│  │                                                         │   │
│  │ - loadGame(id): Future<Game?>                          │   │
│  │ - saveGame(game): Future<void>                         │   │
│  │ - deleteGame(id): Future<void>                         │   │
│  │ - loadAllGames(): Future<List<GameInfo>>               │   │
│  │ - loadGameList(): Future<List<GameInfo>>               │   │
│  │ - saveGameList(games): Future<void>                    │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Repository Implementation                      │
│                     (HiveGameRepository)                         │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Storage Keys:                                           │   │
│  │ - game_list_json  → [GameInfo, GameInfo, ...]          │   │
│  │ - game_{uuid}     → Full Game Data                     │   │
│  │ - last_game_json  → Last Played Game (legacy)          │   │
│  │                                                         │   │
│  │ Methods:                                                │   │
│  │ - JSON Serialization                                    │   │
│  │ - Metadata Syncing                                      │   │
│  │ - Error Handling                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Storage Layer                               │
│                                                                  │
│  ┌──────────────────┐              ┌───────────────────────┐   │
│  │ Hive Database    │              │ SharedPreferences     │   │
│  │                  │              │                       │   │
│  │ - Game Data      │              │ - Theme Settings      │   │
│  │ - Game List      │              │ - User Preferences    │   │
│  │ - NoSQL K-V      │              │ - Lightweight Config  │   │
│  │ - Fast, Local    │              │ - Auto-Persist        │   │
│  └──────────────────┘              └───────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### Creating a New Game

```
User Action: "Create Game" Button
           ↓
    HomeScreen (UI)
           ↓
    Navigate to CreateGameScreen
           ↓
    User enters player names
           ↓
    Tap "Create Game"
           ↓
GameController.createGame(names)
           ↓
    Creates Game instance
    - Generates UUID
    - Assigns colors
    - Sets timestamps
           ↓
    Updates GameState
           ↓
GameRepository.saveGame(game)
           ↓
HiveGameRepository implementation
           ↓
    Serialize to JSON
    Store with key: game_{uuid}
    Update game_list_json
           ↓
    Navigate to Scoreboard
           ↓
    UI Rebuilds with new game
```

### Switching Between Games

```
User Action: Tap game in list
           ↓
    GameListScreen (UI)
           ↓
GameListController.switchToGame(id)
           ↓
    Save current game
           ↓
GameRepository.saveGame(currentGame)
           ↓
    Load selected game
           ↓
GameRepository.loadGame(id)
           ↓
    Update GameListState
    - Set currentGameId
           ↓
    Update GameState
    - Set currentGame
           ↓
    Navigate back
           ↓
    UI Rebuilds with new game
```

### Undo Operation

```
User Action: Tap "Undo" Button
           ↓
    Scoreboard (UI)
           ↓
    UndoController.undo()
           ↓
    Get previous state from history
           ↓
    Decrement currentIndex
           ↓
    Return GameState snapshot
           ↓
GameController.restoreState(snapshot)
           ↓
    Update current game
           ↓
    Save to repository
           ↓
    UI Rebuilds with previous state
```

### Theme Switch

```
User Action: Toggle theme
           ↓
    SettingsScreen (UI)
           ↓
ThemeController.toggleTheme()
           ↓
    Determine new mode
    (light ↔ dark)
           ↓
    Update ThemeState
           ↓
SharedPreferences.setString('theme_mode')
           ↓
    Persist preference
           ↓
    App widget watches ThemeState
           ↓
MaterialApp rebuilds with new theme
           ↓
    All screens update colors
```

## Component Relationships

### State Dependencies

```
┌─────────────────────┐
│   App (Root)        │
│                     │
│ Watches:            │
│ - ThemeController   │
└─────────────────────┘
          │
          ├─────────────────────────────────────┐
          │                                     │
┌─────────▼─────────┐              ┌───────────▼──────────┐
│ HomeScreen        │              │ GameListScreen       │
│                   │              │                      │
│ Watches:          │              │ Watches:             │
│ - GameController  │              │ - GameListController │
└───────────────────┘              └──────────────────────┘
          │                                     │
          │                                     │
┌─────────▼─────────┐              ┌───────────▼──────────┐
│ ScoreboardScreen  │              │ SettingsScreen       │
│                   │              │                      │
│ Watches:          │              │ Watches:             │
│ - GameController  │              │ - ThemeController    │
│ - UndoController  │              └──────────────────────┘
└───────────────────┘
```

### Provider Hierarchy

```
ProviderScope (Root)
    │
    ├── gameRepositoryProvider (Provider)
    │       └── HiveGameRepository instance
    │
    ├── gameControllerProvider (StateNotifierProvider)
    │       ├── Depends on: gameRepositoryProvider
    │       └── Manages: GameState
    │
    ├── gameListControllerProvider (StateNotifierProvider)
    │       ├── Depends on: gameRepositoryProvider
    │       └── Manages: GameListState
    │
    ├── undoControllerProvider (StateNotifierProvider)
    │       └── Manages: UndoState
    │
    └── themeControllerProvider (StateNotifierProvider)
            └── Manages: ThemeState
```

## Storage Structure

### Hive Box Contents

```
HiveBox (Default)
│
├─ "game_list_json" (String)
│  └─ JSON Array: [
│       {
│         "id": "uuid-1",
│         "name": "Friday Night Game",
│         "playerCount": 4,
│         "createdAt": "2024-01-15T19:30:00Z",
│         "lastModified": "2024-01-15T22:45:00Z",
│         "status": "active"
│       },
│       { ... more games ... }
│     ]
│
├─ "game_uuid-1" (String)
│  └─ JSON Object: {
│       "id": "uuid-1",
│       "name": "Friday Night Game",
│       "players": [ ... ],
│       "rounds": [ ... ],
│       "createdAt": "...",
│       "lastModified": "...",
│       "status": "active"
│     }
│
├─ "game_uuid-2" (String)
│  └─ JSON Object: { ... }
│
└─ "last_game_json" (String)
   └─ JSON Object: { ... } (backward compatibility)
```

### SharedPreferences Contents

```
SharedPreferences
│
├─ "theme_mode" (String)
│  └─ "light" | "dark" | "system"
│
└─ "use_system_theme" (bool)
   └─ true | false
```

## Theme System

### Color Inheritance

```
Light Theme                     Dark Theme
    │                               │
    ├─ AppColors                    ├─ AppColorsDark
    │   ├─ primary (#0969DA)        │   ├─ primary (#58A6FF)
    │   ├─ background (#F6F8FA)     │   ├─ background (#0D1117)
    │   ├─ surface (#FFFFFF)        │   ├─ surface (#161B22)
    │   └─ textPrimary (#24292F)    │   └─ textPrimary (#C9D1D9)
    │                               │
    ├─ AppTheme.lightTheme          ├─ AppTheme.darkTheme
    │   ├─ ColorScheme.light        │   ├─ ColorScheme.dark
    │   ├─ TextTheme                │   ├─ TextTheme
    │   ├─ AppBarTheme              │   ├─ AppBarTheme
    │   └─ ComponentThemes          │   └─ ComponentThemes
    │                               │
    └─ Applied to MaterialApp       └─ Applied to MaterialApp
```

### Theme Selection Flow

```
System Theme Enabled?
    │
    ├─ Yes ──→ ThemeMode.system
    │          └─ Follows device setting
    │              ├─ Device Dark → Dark Theme
    │              └─ Device Light → Light Theme
    │
    └─ No ───→ ThemeState.mode
               ├─ ThemeMode.light → Light Theme
               └─ ThemeMode.dark → Dark Theme
```

## Testing Strategy

### Unit Test Coverage

```
State Layer Tests
    │
    ├─ GameController Tests
    │   ├─ createGame()
    │   ├─ addScores()
    │   ├─ recordPredictions()
    │   └─ endGame()
    │
    ├─ GameListController Tests
    │   ├─ switchToGame()
    │   ├─ archiveGame()
    │   ├─ unarchiveGame()
    │   └─ deleteGame()
    │
    ├─ UndoController Tests
    │   ├─ recordState()
    │   ├─ undo()
    │   ├─ redo()
    │   └─ history limit
    │
    └─ ThemeController Tests
        ├─ setThemeMode()
        ├─ toggleTheme()
        └─ persistence
```

### Widget Test Coverage

```
Screen Tests
    │
    ├─ HomeScreen Tests
    │   ├─ Button rendering
    │   ├─ Navigation
    │   └─ State display
    │
    ├─ GameListScreen Tests
    │   ├─ Game list display
    │   ├─ Actions
    │   └─ Empty state
    │
    ├─ SettingsScreen Tests
    │   ├─ Theme controls
    │   ├─ Toggle behavior
    │   └─ Persistence
    │
    └─ Integration Tests
        ├─ Full game flow
        ├─ Multi-game switching
        └─ Theme persistence
```

## Performance Monitoring

### Memory Footprint

```
App Memory Usage
    │
    ├─ State (< 1 MB)
    │   ├─ GameState: ~100 KB
    │   ├─ GameListState: ~50 KB
    │   ├─ UndoState: ~500 KB (50 snapshots)
    │   └─ ThemeState: < 1 KB
    │
    ├─ Storage (Variable)
    │   ├─ Per Game: 5-50 KB
    │   ├─ Game List: ~5 KB
    │   └─ Preferences: < 1 KB
    │
    └─ UI (Variable)
        ├─ Widgets: 5-10 MB
        ├─ Images: (none currently)
        └─ Fonts: ~2 MB
```

## Summary

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Testable components
- ✅ Scalable state management
- ✅ Efficient data storage
- ✅ Flexible theme system
- ✅ Easy to extend

All components are loosely coupled and communicate through well-defined interfaces, making the codebase maintainable and future-proof.
