# Card Game Scorekeeper - Features Documentation

## Overview
A comprehensive Flutter application for tracking card game scores with predictions, statistics, and multiple game management.

## Core Features

### 1. Game Management
#### Multiple Games
- **Create Multiple Games**: Start and manage multiple games simultaneously
- **Game Switching**: Seamlessly switch between active games
- **Game Archiving**: Archive completed games for later reference
- **Game Deletion**: Permanently delete games you no longer need

#### Game Information
Each game tracks:
- Game name/title
- Number of players
- Creation timestamp
- Last modified timestamp
- Game status (Active, Completed, Archived)

### 2. Player Management
- **Dynamic Player Addition**: Add 2-8 players per game
- **Player Names**: Customize player names
- **Player Colors**: Auto-assigned from a palette of 10 vibrant colors
- **Player Statistics**: Track individual player performance

### 3. Score Tracking
#### Round-Based Scoring
- Add scores for each round of play
- Real-time score updates
- Running total calculations
- Per-round score history

#### Score Input
- Clean, intuitive input interface
- Number pad for quick entry
- Visual feedback on score changes
- Undo/redo support for corrections

### 4. Predictions & Analysis
#### Pre-Round Predictions
- Players predict their score before each round
- Prediction accuracy tracking
- Prediction vs actual score comparison

#### Analytics
- **Accuracy Rate**: Percentage of accurate predictions
- **Prediction Trends**: Over/under prediction patterns
- **Performance Metrics**: Win rates, average scores
- **Round Statistics**: Best/worst rounds

### 5. Visual Enhancements
#### GitHub-Inspired Design
- **Light Theme**: Clean, professional appearance with GitHub's light color palette
  - Primary Blue: #0969DA
  - Success Green: #1F883D
  - Warning Orange: #FB8500
  - Background: #F6F8FA
  
- **Dark Theme**: Eye-friendly dark mode
  - Primary Blue: #58A6FF
  - Success Green: #3FB950
  - Background: #0D1117
  - Surface: #161B22

#### UI Elements
- Smooth animations using flutter_animate
- Confetti celebrations for winners
- Charts and graphs with fl_chart
- Loading states with shimmer effects

### 6. History & Statistics
#### Game History
- Complete round-by-round history
- Score evolution charts
- Prediction accuracy timeline
- Player performance comparison

#### Statistics Dashboard
- Lifetime statistics across all games
- Per-game statistics
- Player comparison tools
- Trend analysis

### 7. Theme Support
#### Appearance Options
- **Light Mode**: Traditional bright interface
- **Dark Mode**: Easy on the eyes for low-light environments
- **System Theme**: Automatically follows system preferences
- **Manual Toggle**: Quick switch between themes

#### Theme Persistence
- Remembers your preference
- Syncs across app sessions
- Per-device settings

### 8. Undo/Redo System
#### Action History
- Tracks up to 50 recent actions
- Score changes
- Player additions/removals
- Round completions

#### Undo/Redo Controls
- Undo button: Revert last action
- Redo button: Restore undone action
- Keyboard shortcuts support (planned)
- Visual feedback on available actions

## Feature Roadmap

### Planned Features
1. **Export/Import**: Share games via JSON export
2. **Cloud Sync**: Optional cloud backup (Firebase)
3. **Multiplayer**: Real-time score updates across devices
4. **Custom Scoring**: Support different game types (e.g., negative scoring)
5. **Game Templates**: Save and reuse game configurations
6. **Player Profiles**: Persistent player data across games
7. **Achievements**: Unlock badges and milestones
8. **Game Rules**: Built-in rules for popular card games
9. **Timer**: Optional round/game timer
10. **Sound Effects**: Audio feedback (toggle on/off)
11. **Leaderboards**: Compare with friends
12. **Custom Themes**: User-defined color schemes

## Technical Highlights

### State Management
- **Riverpod 2.4.9**: Type-safe, testable state management
- **StateNotifier**: Predictable state mutations
- **Provider Architecture**: Separation of concerns

### Data Persistence
- **Hive**: Fast, local NoSQL database
- **SharedPreferences**: Settings and preferences
- **JSON Serialization**: Portable game data format

### Navigation
- **go_router**: Declarative routing
- **Deep Linking**: URL-based navigation
- **Route Guards**: Access control (planned)

### Performance
- **Lazy Loading**: Load games on demand
- **Efficient Updates**: Minimal rebuilds
- **Memory Management**: Automatic cleanup
- **Optimized Assets**: Compressed images and fonts

## User Workflows

### Starting a New Game
1. Tap "Start New Game" on home screen
2. Enter player names (2-8 players)
3. Auto-assign colors or customize
4. Begin first round

### Playing a Round
1. View scoreboard with current standings
2. Enter predictions (optional)
3. Play the round
4. Enter actual scores
5. Review results and statistics
6. Proceed to next round or end game

### Managing Multiple Games
1. Access game list from home screen
2. View all active and archived games
3. Switch to different game
4. Archive completed games
5. Delete unwanted games

### Customizing Appearance
1. Open settings from home screen
2. Choose theme preference
3. Toggle system theme following
4. Changes apply immediately

## Accessibility Features

### Current
- High contrast colors
- Readable font sizes
- Clear button labels
- Visual feedback

### Planned
- Screen reader support
- Font size controls
- Color blind mode
- Voice input

## Platform Support
- **Android**: Full support
- **iOS**: Full support (pending testing)
- **Web**: Fully functional via Flutter Web
- **Desktop**: Compatible (Windows, macOS, Linux)

## Browser Compatibility (Web)
- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support
- Mobile browsers: ✅ Responsive design
