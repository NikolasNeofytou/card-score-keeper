import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tichu_engine/tichu_engine.dart';
import 'room/game_room.dart';
import 'room/client_connection.dart';
import 'models/message.dart';

class TichuServer {
  final int port;
  final RoomManager roomManager;
  final Map<String, ClientConnection> _connections = {};
  
  HttpServer? _server;
  Timer? _cleanupTimer;

  TichuServer({this.port = 8080})
      : roomManager = RoomManager();

  /// Start the server
  Future<void> start() async {
    final handler = Cascade()
        .add(_createWebSocketHandler())
        .add(_createHttpHandler())
        .handler;

    _server = await shelf_io.serve(
      handler,
      InternetAddress.anyIPv4,
      port,
    );

    // Start cleanup timer (every 15 minutes)
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => roomManager.cleanupInactiveRooms(),
    );

    print('✅ Tichu server running on port $port');
  }

  /// Stop the server
  Future<void> stop() async {
    _cleanupTimer?.cancel();
    
    for (final connection in _connections.values) {
      connection.dispose();
    }
    _connections.clear();

    await _server?.close(force: true);
    print('🛑 Tichu server stopped');
  }

  /// Create WebSocket handler
  Handler _createWebSocketHandler() {
    return webSocketHandler((WebSocketChannel channel) {
      ClientConnection? connection;

      channel.stream.listen(
        (message) {
          if (connection == null) {
            // First message should be connect with player info
            try {
              final msg = WebSocketMessage.fromJsonString(message);
              if (msg.type == MessageType.connect && msg.playerId != null) {
                connection = ClientConnection(
                  playerId: msg.playerId!,
                  playerName: msg.payload['playerName'] ?? 'Anonymous',
                  channel: channel,
                );
                _connections[msg.playerId!] = connection!;
                _handleClientMessages(connection!);
                
                connection!.send(WebSocketMessage(
                  type: MessageType.connect,
                  payload: {'status': 'connected', 'playerId': msg.playerId},
                ));
              }
            } catch (e) {
              channel.sink.add(jsonEncode({
                'type': 'error',
                'message': 'Connection failed: ${e.toString()}',
              }));
              channel.sink.close();
            }
          } else {
            connection!.handleMessage(message);
          }
        },
        onDone: () {
          if (connection != null) {
            _handleDisconnect(connection!);
          }
        },
        onError: (error) {
          if (connection != null) {
            _handleDisconnect(connection!);
          }
        },
      );
    });
  }

  /// Handle messages from a client
  void _handleClientMessages(ClientConnection connection) {
    connection.messages.listen((message) {
      try {
        _routeMessage(connection, message);
      } catch (e) {
        connection.send(ErrorMessage(
          message: 'Error handling message: ${e.toString()}',
          playerId: connection.playerId,
        ));
      }
    });
  }

  /// Route message to appropriate handler
  void _routeMessage(ClientConnection connection, WebSocketMessage message) {
    switch (message.type) {
      case MessageType.createRoom:
        _handleCreateRoom(connection, message);
        break;

      case MessageType.joinRoom:
        _handleJoinRoom(connection, message);
        break;

      case MessageType.leaveRoom:
        _handleLeaveRoom(connection);
        break;

      case MessageType.makeMove:
        _handleMakeMove(connection, message);
        break;

      case MessageType.pong:
        connection.lastPing = DateTime.now();
        break;

      default:
        connection.send(ErrorMessage(
          message: 'Unknown message type: ${message.type}',
          playerId: connection.playerId,
        ));
    }
  }

  void _handleCreateRoom(ClientConnection connection, WebSocketMessage message) {
    final rulesData = message.payload['rules'] as Map<String, dynamic>?;
    final ruleset = rulesData != null
        ? TichuRuleset.fromJson(rulesData)
        : TichuRuleset.standard();

    final room = roomManager.createRoom(
      hostPlayerId: connection.playerId,
      ruleset: ruleset,
    );

    roomManager.joinRoom(room.id, connection);

    connection.send(WebSocketMessage(
      type: MessageType.roomState,
      roomId: room.id,
      payload: {
        'roomId': room.id,
        'status': 'created',
        'playerCount': 1,
      },
    ));
  }

  void _handleJoinRoom(ClientConnection connection, WebSocketMessage message) {
    final roomId = message.roomId;
    if (roomId == null) {
      connection.send(ErrorMessage(
        message: 'Room ID required',
        playerId: connection.playerId,
      ));
      return;
    }

    final joined = roomManager.joinRoom(roomId, connection);
    if (!joined) {
      connection.send(ErrorMessage(
        message: 'Could not join room (full or not found)',
        playerId: connection.playerId,
      ));
      return;
    }

    connection.send(WebSocketMessage(
      type: MessageType.roomState,
      roomId: roomId,
      payload: {'status': 'joined'},
    ));
  }

  void _handleLeaveRoom(ClientConnection connection) {
    roomManager.leaveRoom(connection.playerId);
  }

  void _handleMakeMove(ClientConnection connection, WebSocketMessage message) {
    final room = roomManager.getRoomForPlayer(connection.playerId);
    if (room == null) {
      connection.send(ErrorMessage(
        message: 'Not in a room',
        playerId: connection.playerId,
      ));
      return;
    }

    final moveData = message.payload['move'] as Map<String, dynamic>?;
    if (moveData == null) {
      connection.send(ErrorMessage(
        message: 'Move data required',
        playerId: connection.playerId,
      ));
      return;
    }

    final move = TichuMove.fromJson(moveData);
    room.handleMove(connection.playerId, move);
  }

  void _handleDisconnect(ClientConnection connection) {
    roomManager.leaveRoom(connection.playerId);
    _connections.remove(connection.playerId);
    connection.dispose();
  }

  /// Create HTTP handler for status and health checks
  Handler _createHttpHandler() {
    return (Request request) {
      if (request.url.path == 'health') {
        return Response.ok(
          jsonEncode({
            'status': 'healthy',
            'rooms': roomManager.listRooms().length,
            'connections': _connections.length,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (request.url.path == 'rooms') {
        final rooms = roomManager.listRooms().map((room) => {
              'id': room.id,
              'state': room.state.name,
              'playerCount': room.playerCount,
            }).toList();

        return Response.ok(
          jsonEncode({'rooms': rooms}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.notFound('Not found');
    };
  }
}
