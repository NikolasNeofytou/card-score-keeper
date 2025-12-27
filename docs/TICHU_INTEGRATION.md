# Tichu Game Integration Guide

## Overview

This project now includes a complete Tichu card game engine and multiplayer server:

- **`packages/tichu_engine`** - Pure Dart package with game logic
- **`services/tichu_server`** - WebSocket server for multiplayer

## Working with the Packages (Using Docker)

Since Dart SDK is inside Docker, use these commands:

### Build and Test Tichu Engine

```powershell
# Get dependencies
docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart pub get

# Generate JSON serialization code
docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart run build_runner build --delete-conflicting-outputs

# Run tests
docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart test
```

### Run Tichu Server

```powershell
# Get dependencies
docker run --rm -v ${PWD}/services/tichu_server:/app -w /app dart:stable dart pub get

# Run server
docker run --rm -p 8080:8080 -v ${PWD}/services/tichu_server:/app -v ${PWD}/packages/tichu_engine:/packages/tichu_engine -w /app dart:stable dart bin/server.dart
```

## Quick Commands

Create a helper script `tichu-dev.ps1`:

```powershell
param(
    [string]$Command
)

switch ($Command) {
    "engine-deps" {
        docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart pub get
    }
    "engine-build" {
        docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart run build_runner build --delete-conflicting-outputs
    }
    "engine-test" {
        docker run --rm -v ${PWD}/packages/tichu_engine:/app -w /app dart:stable dart test
    }
    "server-run" {
        docker run --rm -p 8080:8080 -v ${PWD}/services/tichu_server:/app -v ${PWD}/packages/tichu_engine:/packages/tichu_engine -w /app dart:stable dart bin/server.dart
    }
    default {
        Write-Host "Usage: .\tichu-dev.ps1 [engine-deps|engine-build|engine-test|server-run]"
    }
}
```

## Package Structure

### Tichu Engine (`packages/tichu_engine`)

```
lib/
  src/
    models/
      card.dart           # Card model (regular + special)
      suit.dart           # 4 suits (jade, sword, pagoda, star)
      rank.dart           # 13 ranks (2-A)
      special_card.dart   # Dragon, Phoenix, Dog, Mahjong
      game_state.dart     # Complete game state
      player_state.dart   # Individual player state
      move.dart           # Player moves
      combination.dart    # Card combinations
    services/
      deck_factory.dart   # Create, shuffle, deal
      scoring_service.dart # Calculate scores
      game_validator.dart # Validate moves
    config/
      ruleset.dart        # Game rules configuration
test/
  tichu_engine_test.dart # Comprehensive tests
```

### Tichu Server (`services/tichu_server`)

```
lib/
  src/
    server.dart           # Main WebSocket server
    models/
      message.dart        # WebSocket protocol
    room/
      game_room.dart      # Game room management
      client_connection.dart # Client connections
bin/
  server.dart            # Entry point
```

## Integration with Main App

### Add to pubspec.yaml

```yaml
dependencies:
  tichu_engine:
    path: packages/tichu_engine
  web_socket_channel: ^2.4.0
```

### WebSocket Client Example

```dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tichu_engine/tichu_engine.dart';

class TichuClient {
  final WebSocketChannel channel;
  
  TichuClient(String serverUrl)
      : channel = WebSocketChannel.connect(Uri.parse(serverUrl));
  
  void connect(String playerId, String playerName) {
    channel.sink.add(jsonEncode({
      'type': 'connect',
      'playerId': playerId,
      'payload': {'playerName': playerName},
    }));
  }
  
  void createRoom() {
    channel.sink.add(jsonEncode({
      'type': 'createRoom',
      'playerId': playerId,
      'payload': {
        'playerName': playerName,
        'rules': TichuRuleset.standard().toJson(),
      },
    }));
  }
  
  Stream<Map<String, dynamic>> get messages =>
      channel.stream.map((msg) => jsonDecode(msg));
}
```

## Tichu Game Rules

### Cards (56 total)
- **Regular Cards (52)**: 4 suits × 13 ranks (2-A)
- **Special Cards (4)**:
  - 🀄 Mahjong - Value 1, leads, can wish for rank
  - 🐕 Dog - Value 0, passes to partner
  - 🦅 Phoenix - Value 1.5, wild card, -25 points
  - 🐉 Dragon - Highest card, +25 points

### Scoring
- **Card Points**: 5=5pts, 10=10pts, K=10pts
- **Special Cards**: Dragon=+25pts, Phoenix=-25pts
- **Tichu**: ±100 points (call before playing first card)
- **Grand Tichu**: ±200 points (call before seeing 9th card)
- **Double Victory**: 200 points (team finishes 1-2)

### Combinations
1. **Single** - 1 card
2. **Pair** - 2 same rank
3. **Triple** - 3 same rank
4. **Full House** - 3 + 2
5. **Straight** - 5+ consecutive
6. **Bomb** - 4 of a kind OR straight flush

### Game Flow
1. **Setup**: Deal 8 cards, Grand Tichu calls, deal remaining 6
2. **Trading**: Trade 3 cards (left, right, across)
3. **Playing**: Play combinations, beat previous or pass
4. **Scoring**: First out wins trick for partner
5. **Victory**: First team to 1000 points

## Development Workflow

### 1. Make Changes to Engine
```powershell
# Edit files in packages/tichu_engine/lib/

# Generate code if models changed
.\tichu-dev.ps1 engine-build

# Run tests
.\tichu-dev.ps1 engine-test
```

### 2. Test Multiplayer Server
```powershell
# Start server
.\tichu-dev.ps1 server-run

# In another terminal, test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/rooms
```

### 3. Connect from Flutter App
```dart
final client = TichuClient('ws://localhost:8080');
client.connect('player-uuid', 'Alice');
client.messages.listen((msg) {
  print('Received: $msg');
});
```

## Testing WebSocket Server

Use PowerShell with web socket client:

```powershell
# Install websocket client if needed
# Then connect:
wscat -c ws://localhost:8080
# Send: {"type":"connect","playerId":"test1","payload":{"playerName":"Test"}}
```

## Next Steps

1. ✅ Packages created
2. ⏳ Generate JSON serialization (run `engine-build`)
3. ⏳ Run tests (run `engine-test`)
4. ⏳ Add Tichu to main app navigation
5. ⏳ Create Tichu UI screens in Flutter
6. ⏳ Connect Flutter app to WebSocket server
7. ⏳ Add Tichu game to docker-compose

## Docker Compose Integration

To add Tichu server to your docker-compose.yml:

```yaml
services:
  tichu-server:
    image: dart:stable
    working_dir: /app
    volumes:
      - ./services/tichu_server:/app
      - ./packages/tichu_engine:/packages/tichu_engine
    command: sh -c "cd /app && dart pub get && dart bin/server.dart"
    ports:
      - "8080:8080"
    networks:
      - app-network
```

## Troubleshooting

### "Dart not recognized"
Use Docker commands above, or install Flutter SDK locally.

### JSON serialization errors
Run: `.\tichu-dev.ps1 engine-build`

### WebSocket connection failed
Check server is running: `curl http://localhost:8080/health`

### Tests failing
Ensure dependencies installed: `.\tichu-dev.ps1 engine-deps`
