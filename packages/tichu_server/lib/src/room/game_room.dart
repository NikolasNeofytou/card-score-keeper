import 'dart:async';
import 'package:tichu_engine/tichu_engine.dart';
import 'package:uuid/uuid.dart';
import 'client_connection.dart';
import '../models/message.dart';

const _uuid = Uuid();

enum RoomState {
  waiting,    // Waiting for players
  ready,      // 4 players joined
  playing,    // Game in progress
  finished,   // Game ended
}

/// Represents a multiplayer game room
class GameRoom {
  final String id;
  final String hostPlayerId;
  final TichuRuleset ruleset;
  final Map<String, ClientConnection> clients;
  final StreamController<WebSocketMessage> _messageController;
  
  TichuGameState? gameState;
  RoomState state;
  DateTime createdAt;
  DateTime lastActivity;

  GameRoom({
    required this.id,
    required this.hostPlayerId,
    required this.ruleset,
  })  : clients = {},
        state = RoomState.waiting,
        createdAt = DateTime.now(),
        lastActivity = DateTime.now(),
        _messageController = StreamController<WebSocketMessage>.broadcast();

  Stream<WebSocketMessage> get messages => _messageController.stream;

  int get playerCount => clients.length;
  bool get isFull => playerCount >= 4;
  bool get canStart => playerCount == 4 && state == RoomState.ready;

  /// Add a player to the room
  bool addPlayer(ClientConnection client) {
    if (isFull) return false;

    clients[client.playerId] = client;
    lastActivity = DateTime.now();

    if (playerCount == 4) {
      state = RoomState.ready;
      _startGame();
    }

    _broadcastRoomState();
    return true;
  }

  /// Remove a player from the room
  void removePlayer(String playerId) {
    clients.remove(playerId);
    lastActivity = DateTime.now();

    if (state == RoomState.playing) {
      // End game if player leaves during play
      state = RoomState.finished;
    } else if (playerCount < 4) {
      state = RoomState.waiting;
    }

    _broadcastRoomState();
  }

  /// Handle a player move
  Future<void> handleMove(String playerId, TichuMove move) async {
    if (gameState == null || state != RoomState.playing) {
      _sendError(playerId, 'Game not in progress');
      return;
    }

    // Validate move
    final result = GameValidator.validateMove(gameState!, move);
    if (!result.isValid) {
      _sendError(playerId, result.errorMessage ?? 'Invalid move');
      return;
    }

    // Apply move (this would need to be implemented in the engine)
    // For now, just broadcast the move
    _broadcast(WebSocketMessage(
      type: MessageType.gameUpdate,
      roomId: id,
      payload: {
        'move': move.toJson(),
        'playerId': playerId,
      },
    ));

    lastActivity = DateTime.now();
  }

  /// Start the game
  void _startGame() {
    // Create and shuffle deck
    final deck = DeckFactory.shuffleDeck(DeckFactory.createDeck());
    final hands = DeckFactory.dealCards(deck);

    // Create player states
    final players = <PlayerState>[];
    int index = 0;
    for (final client in clients.values) {
      players.add(PlayerState(
        id: client.playerId,
        name: client.playerName,
        hand: hands[index]!,
      ));
      index++;
    }

    // Initialize game state
    gameState = TichuGameState(
      id: id,
      players: players,
      phase: GamePhase.setup,
    );

    state = RoomState.playing;
    _broadcastGameState();
  }

  /// Broadcast room state to all clients
  void _broadcastRoomState() {
    final message = WebSocketMessage(
      type: MessageType.roomState,
      roomId: id,
      payload: {
        'roomId': id,
        'state': state.name,
        'playerCount': playerCount,
        'players': clients.values
            .map((c) => {
                  'id': c.playerId,
                  'name': c.playerName,
                })
            .toList(),
      },
    );
    _broadcast(message);
  }

  /// Broadcast game state to all clients
  void _broadcastGameState() {
    if (gameState == null) return;

    // Send personalized game state to each player (hide other players' hands)
    for (final client in clients.values) {
      final personalizedState = _personalizeGameState(client.playerId);
      final message = GameStateMessage(
        roomId: id,
        gameState: personalizedState.toJson(),
      );
      client.send(message);
    }
  }

  /// Create personalized game state (hide other players' hands)
  TichuGameState _personalizeGameState(String playerId) {
    if (gameState == null) throw StateError('No game state');

    final players = gameState!.players.map((player) {
      if (player.id == playerId) {
        return player; // Show full hand
      } else {
        // Hide hand, only show hand size
        return player.copyWith(
          hand: List.filled(
            player.handSize,
            const TichuCard.special(special: SpecialCard.dog), // Placeholder
          ),
        );
      }
    }).toList();

    return gameState!.copyWith(players: players);
  }

  /// Send error to specific player
  void _sendError(String playerId, String message) {
    final client = clients[playerId];
    if (client != null) {
      client.send(ErrorMessage(
        message: message,
        roomId: id,
        playerId: playerId,
      ));
    }
  }

  /// Broadcast message to all clients
  void _broadcast(WebSocketMessage message) {
    _messageController.add(message);
    for (final client in clients.values) {
      client.send(message);
    }
  }

  void dispose() {
    _messageController.close();
  }
}

/// Manages all game rooms
class RoomManager {
  final Map<String, GameRoom> _rooms = {};
  final Map<String, String> _playerRooms = {}; // playerId -> roomId

  /// Create a new room
  GameRoom createRoom({
    required String hostPlayerId,
    TichuRuleset? ruleset,
  }) {
    final roomId = _uuid.v4().substring(0, 6).toUpperCase();
    final room = GameRoom(
      id: roomId,
      hostPlayerId: hostPlayerId,
      ruleset: ruleset ?? TichuRuleset.standard(),
    );

    _rooms[roomId] = room;
    return room;
  }

  /// Get a room by ID
  GameRoom? getRoom(String roomId) => _rooms[roomId];

  /// Join a room
  bool joinRoom(String roomId, ClientConnection client) {
    final room = _rooms[roomId];
    if (room == null) return false;

    if (room.addPlayer(client)) {
      _playerRooms[client.playerId] = roomId;
      return true;
    }

    return false;
  }

  /// Leave a room
  void leaveRoom(String playerId) {
    final roomId = _playerRooms[playerId];
    if (roomId == null) return;

    final room = _rooms[roomId];
    if (room != null) {
      room.removePlayer(playerId);

      // Remove empty rooms
      if (room.playerCount == 0) {
        room.dispose();
        _rooms.remove(roomId);
      }
    }

    _playerRooms.remove(playerId);
  }

  /// Get room for a player
  GameRoom? getRoomForPlayer(String playerId) {
    final roomId = _playerRooms[playerId];
    return roomId != null ? _rooms[roomId] : null;
  }

  /// List all rooms
  List<GameRoom> listRooms() => _rooms.values.toList();

  /// Clean up inactive rooms (older than 1 hour with no activity)
  void cleanupInactiveRooms() {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _rooms.entries) {
      final room = entry.value;
      final inactive = now.difference(room.lastActivity).inHours > 1;

      if (inactive || room.state == RoomState.finished) {
        toRemove.add(entry.key);
        room.dispose();

        // Remove player mappings
        for (final playerId in room.clients.keys) {
          _playerRooms.remove(playerId);
        }
      }
    }

    for (final roomId in toRemove) {
      _rooms.remove(roomId);
    }
  }
}
