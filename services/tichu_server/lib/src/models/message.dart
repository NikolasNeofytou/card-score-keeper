import 'dart:convert';

/// WebSocket message types for Tichu multiplayer
enum MessageType {
  // Connection
  connect,
  disconnect,
  
  // Room management
  createRoom,
  joinRoom,
  leaveRoom,
  roomState,
  
  // Game actions
  makeMove,
  gameState,
  gameUpdate,
  
  // Player actions
  callTichu,
  callGrandTichu,
  playCards,
  pass,
  trade,
  
  // System
  error,
  ping,
  pong,
}

/// Base message structure
class WebSocketMessage {
  final MessageType type;
  final Map<String, dynamic> payload;
  final String? roomId;
  final String? playerId;
  final int timestamp;

  WebSocketMessage({
    required this.type,
    this.payload = const {},
    this.roomId,
    this.playerId,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'payload': payload,
        'roomId': roomId,
        'playerId': playerId,
        'timestamp': timestamp,
      };

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: MessageType.values.firstWhere((t) => t.name == json['type']),
      payload: json['payload'] ?? {},
      roomId: json['roomId'],
      playerId: json['playerId'],
      timestamp: json['timestamp'],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory WebSocketMessage.fromJsonString(String jsonString) {
    return WebSocketMessage.fromJson(jsonDecode(jsonString));
  }
}

/// Create room request
class CreateRoomMessage extends WebSocketMessage {
  CreateRoomMessage({
    required String playerId,
    required String playerName,
    Map<String, dynamic> rules = const {},
  }) : super(
          type: MessageType.createRoom,
          playerId: playerId,
          payload: {
            'playerName': playerName,
            'rules': rules,
          },
        );
}

/// Join room request
class JoinRoomMessage extends WebSocketMessage {
  JoinRoomMessage({
    required String roomId,
    required String playerId,
    required String playerName,
  }) : super(
          type: MessageType.joinRoom,
          roomId: roomId,
          playerId: playerId,
          payload: {'playerName': playerName},
        );
}

/// Make move request
class MakeMoveMessage extends WebSocketMessage {
  MakeMoveMessage({
    required String roomId,
    required String playerId,
    required Map<String, dynamic> move,
  }) : super(
          type: MessageType.makeMove,
          roomId: roomId,
          playerId: playerId,
          payload: {'move': move},
        );
}

/// Game state update (server -> clients)
class GameStateMessage extends WebSocketMessage {
  GameStateMessage({
    required String roomId,
    required Map<String, dynamic> gameState,
  }) : super(
          type: MessageType.gameState,
          roomId: roomId,
          payload: {'gameState': gameState},
        );
}

/// Error message
class ErrorMessage extends WebSocketMessage {
  ErrorMessage({
    required String message,
    String? code,
    String? roomId,
    String? playerId,
  }) : super(
          type: MessageType.error,
          roomId: roomId,
          playerId: playerId,
          payload: {
            'message': message,
            'code': code,
          },
        );
}
