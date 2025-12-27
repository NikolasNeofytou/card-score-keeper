import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';

/// Represents a connected client
class ClientConnection {
  final String playerId;
  final String playerName;
  final WebSocketChannel channel;
  final StreamController<WebSocketMessage> _messageController;
  
  DateTime connectedAt;
  DateTime lastPing;

  ClientConnection({
    required this.playerId,
    required this.playerName,
    required this.channel,
  })  : connectedAt = DateTime.now(),
        lastPing = DateTime.now(),
        _messageController = StreamController<WebSocketMessage>();

  Stream<WebSocketMessage> get messages => _messageController.stream;

  /// Send a message to the client
  void send(WebSocketMessage message) {
    try {
      channel.sink.add(message.toJsonString());
    } catch (e) {
      // Connection closed
    }
  }

  /// Handle incoming message from client
  void handleMessage(String data) {
    try {
      final message = WebSocketMessage.fromJsonString(data);
      _messageController.add(message);
    } catch (e) {
      send(ErrorMessage(
        message: 'Invalid message format',
        code: 'INVALID_MESSAGE',
        playerId: playerId,
      ));
    }
  }

  /// Ping the client
  void ping() {
    send(WebSocketMessage(type: MessageType.ping));
    lastPing = DateTime.now();
  }

  /// Check if connection is alive
  bool get isAlive {
    final now = DateTime.now();
    return now.difference(lastPing).inSeconds < 30;
  }

  void dispose() {
    _messageController.close();
    channel.sink.close();
  }
}
