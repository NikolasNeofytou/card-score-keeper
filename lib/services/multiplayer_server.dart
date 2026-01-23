import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../domain/models/game.dart';
import '../domain/models/player.dart';
import '../domain/models/round.dart';

class MultiplayerGameServer {
  HttpServer? _server;
  final Map<String, WebSocketChannel> _clients = {};
  final Map<String, Game> _games = {};
  int _port = 8080;

  String? get serverAddress =>
      _server != null ? 'http://localhost:$_port' : null;
  String? get gameUrl => serverAddress != null ? '$serverAddress/join' : null;

  // Start the server with a specific game
  Future<String?> startGameServer(Game game) async {
    try {
      // Find available port
      _port = await _findAvailablePort();

      // Store the game
      _games[game.id] = game;

      final handler = Cascade()
          .add(_createWebSocketHandler())
          .add(_createHttpHandler())
          .handler;

      _server = await io.serve(handler, '0.0.0.0', _port);

      print('🎮 Game server started on http://localhost:$_port');
      print('📱 Game ID: ${game.id}');
      print('🔗 Join URL: $gameUrl');

      return gameUrl;
    } catch (e) {
      print('❌ Failed to start server: $e');
      return null;
    }
  }

  // Create WebSocket handler for real-time communication
  Handler _createWebSocketHandler() {
    return webSocketHandler((WebSocketChannel webSocket) {
      final clientId = DateTime.now().millisecondsSinceEpoch.toString();
      _clients[clientId] = webSocket;

      print('📱 Client connected: $clientId');

      webSocket.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _handleClientMessage(clientId, data);
        },
        onDone: () {
          _clients.remove(clientId);
          print('📱 Client disconnected: $clientId');
        },
        onError: (error) {
          print('❌ WebSocket error for $clientId: $error');
          _clients.remove(clientId);
        },
      );
    });
  }

  // Create HTTP handler for join requests
  Handler _createHttpHandler() {
    return (Request request) {
      if (request.method == 'GET' && request.url.path == 'join') {
        return _handleJoinRequest(request);
      }

      if (request.method == 'GET' && request.url.path == 'game-info') {
        return _handleGameInfoRequest(request);
      }

      return Response.notFound('Not found');
    };
  }

  // Handle join requests from QR code scanning
  Response _handleJoinRequest(Request request) {
    final gameId = request.url.queryParameters['gameId'];

    if (gameId == null || !_games.containsKey(gameId)) {
      return Response.badRequest(
          body: jsonEncode({
        'error': 'Invalid game ID',
        'gameId': gameId,
      }));
    }

    final game = _games[gameId]!;
    return Response.ok(
      jsonEncode({
        'success': true,
        'game': _gameToJson(game),
        'message': 'Successfully joined ${game.name}',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Handle game info requests
  Response _handleGameInfoRequest(Request request) {
    final gameId = request.url.queryParameters['gameId'];

    if (gameId == null || !_games.containsKey(gameId)) {
      return Response.badRequest(
          body: jsonEncode({
        'error': 'Game not found',
      }));
    }

    final game = _games[gameId]!;
    return Response.ok(
      jsonEncode({
        'game': _gameToJson(game),
        'clientsConnected': _clients.length,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Handle messages from clients
  void _handleClientMessage(String clientId, Map<String, dynamic> data) {
    final action = data['action'];
    final gameId = data['gameId'];

    if (gameId == null || !_games.containsKey(gameId)) {
      _sendToClient(clientId, {'error': 'Invalid game ID'});
      return;
    }

    switch (action) {
      case 'subscribe':
        _sendToClient(clientId, {
          'action': 'game_update',
          'game': _gameToJson(_games[gameId]!),
        });
        break;

      case 'update_game':
        // Update game state from host
        if (data['game'] != null) {
          // In a real implementation, you'd validate the sender is the host
          _updateGameFromJson(gameId, data['game']);
          _broadcastGameUpdate(gameId);
        }
        break;
    }
  }

  // Update game state from JSON
  void _updateGameFromJson(String gameId, Map<String, dynamic> gameJson) {
    // This is a simplified implementation
    // In production, you'd want proper deserialization
    final game = _games[gameId]!;

    // Update basic properties
    if (gameJson['currentRoundIndex'] != null) {
      // Update round index and other game state
      print('🔄 Game updated: ${game.name}');
    }
  }

  // Broadcast game updates to all connected clients
  void _broadcastGameUpdate(String gameId) {
    if (!_games.containsKey(gameId)) return;

    final game = _games[gameId]!;
    final message = jsonEncode({
      'action': 'game_update',
      'game': _gameToJson(game),
      'timestamp': DateTime.now().toIso8601String(),
    });

    _clients.forEach((clientId, channel) {
      try {
        channel.sink.add(message);
      } catch (e) {
        print('❌ Failed to send to client $clientId: $e');
        _clients.remove(clientId);
      }
    });
  }

  // Convert game to JSON for network transmission
  Map<String, dynamic> _gameToJson(Game game) {
    return {
      'id': game.id,
      'name': game.name,
      'state': game.state.name,
      'currentRoundIndex': game.currentRoundIndex,
      'players': game.players
          .map((p) => {
                'id': p.id,
                'name': p.name,
              })
          .toList(),
      'rounds': game.rounds
          .map((r) => {
                'cards': r.cards,
                'status': r.status.name,
                'entries': r.entries
                    .map((e) => {
                          'playerId': e.playerId,
                          'predictedWins': e.predictedWins,
                          'actualWins': e.actualWins,
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  // Send message to specific client
  void _sendToClient(String clientId, Map<String, dynamic> message) {
    final channel = _clients[clientId];
    if (channel != null) {
      try {
        channel.sink.add(jsonEncode(message));
      } catch (e) {
        print('❌ Failed to send to client $clientId: $e');
        _clients.remove(clientId);
      }
    }
  }

  // Update game state (called from game controller)
  void updateGame(Game game) {
    _games[game.id] = game;
    _broadcastGameUpdate(game.id);
    print('📡 Broadcasting game update to ${_clients.length} clients');
  }

  // Find an available port
  Future<int> _findAvailablePort() async {
    for (int port = 8080; port <= 8090; port++) {
      try {
        final serverSocket = await ServerSocket.bind('localhost', port);
        await serverSocket.close();
        return port;
      } catch (e) {
        continue;
      }
    }
    return 8080; // Fallback
  }

  // Stop the server
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _clients.clear();
      _games.clear();
      print('🛑 Game server stopped');
    }
  }
}
