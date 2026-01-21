# Tichu WebSocket Server

Multiplayer server for Tichu card game using WebSockets.

## Features

- **Room Management**: Create and join game rooms (4 players per room)
- **WebSocket Communication**: Real-time bidirectional messaging
- **Game State Sync**: Automatic state synchronization across clients
- **Move Validation**: Server-side validation using tichu_engine
- **Personalized Views**: Each player sees only their own hand
- **Auto Cleanup**: Inactive rooms cleaned up automatically
- **Health Checks**: HTTP endpoints for monitoring

## Running the Server

```bash
dart bin/server.dart [port]
```

Default port: 8080

## WebSocket Protocol

### Connection
```json
{
  "type": "connect",
  "playerId": "player-uuid",
  "payload": {
    "playerName": "Alice"
  }
}
```

### Create Room
```json
{
  "type": "createRoom",
  "playerId": "player-uuid",
  "payload": {
    "playerName": "Alice",
    "rules": {
      "targetScore": 1000,
      "allowDoubleVictory": true
    }
  }
}
```

### Join Room
```json
{
  "type": "joinRoom",
  "roomId": "ABC123",
  "playerId": "player-uuid",
  "payload": {
    "playerName": "Bob"
  }
}
```

### Make Move
```json
{
  "type": "makeMove",
  "roomId": "ABC123",
  "playerId": "player-uuid",
  "payload": {
    "move": {
      "playerId": "player-uuid",
      "type": "play",
      "cards": [...]
    }
  }
}
```

### Game State (Server → Client)
```json
{
  "type": "gameState",
  "roomId": "ABC123",
  "payload": {
    "gameState": {
      "id": "ABC123",
      "players": [...],
      "phase": "playing",
      "currentPlayerIndex": 0
    }
  }
}
```

## HTTP Endpoints

### Health Check
```
GET http://localhost:8080/health
```

Response:
```json
{
  "status": "healthy",
  "rooms": 3,
  "connections": 12
}
```

### List Rooms
```
GET http://localhost:8080/rooms
```

Response:
```json
{
  "rooms": [
    {
      "id": "ABC123",
      "state": "playing",
      "playerCount": 4
    }
  ]
}
```

## Message Types

- `connect` - Initial connection
- `createRoom` - Create new game room
- `joinRoom` - Join existing room
- `leaveRoom` - Leave current room
- `makeMove` - Submit a game move
- `gameState` - Full game state (server → client)
- `gameUpdate` - Partial update (server → client)
- `roomState` - Room status update (server → client)
- `error` - Error message (server → client)
- `ping` / `pong` - Keep-alive

## Room States

- `waiting` - Less than 4 players
- `ready` - 4 players joined, ready to start
- `playing` - Game in progress
- `finished` - Game ended

## Architecture

```
bin/server.dart           - Entry point
lib/
  src/
    server.dart           - Main server class
    models/
      message.dart        - WebSocket message types
    room/
      game_room.dart      - Game room management
      client_connection.dart - Client wrapper
```

## Integration with Flutter App

Add WebSocket client in Flutter:

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('ws://localhost:8080'),
);

// Connect
channel.sink.add(jsonEncode({
  'type': 'connect',
  'playerId': uuid,
  'payload': {'playerName': 'Alice'},
}));

// Listen for messages
channel.stream.listen((message) {
  final msg = WebSocketMessage.fromJsonString(message);
  // Handle message
});
```

## Security Considerations

For production:
- Add authentication/authorization
- Implement rate limiting
- Add SSL/TLS (wss://)
- Validate all inputs
- Add player session management
- Implement reconnection logic

## License

MIT
