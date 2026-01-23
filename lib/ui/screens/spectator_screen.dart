import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../domain/models/game.dart';
import '../../domain/models/player.dart';
import '../../domain/models/round.dart';

class SpectatorScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> gameData;
  final String serverUrl;
  final String message;

  const SpectatorScreen({
    super.key,
    required this.gameData,
    required this.serverUrl,
    required this.message,
  });

  @override
  ConsumerState<SpectatorScreen> createState() => _SpectatorScreenState();
}

class _SpectatorScreenState extends ConsumerState<SpectatorScreen> {
  WebSocketChannel? _channel;
  Map<String, dynamic>? _currentGameData;
  bool _isConnected = false;
  String _connectionStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _currentGameData = widget.gameData;
    _connectToWebSocket();

    // Show welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.message),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void _connectToWebSocket() {
    try {
      // Convert HTTP URL to WebSocket URL
      final wsUrl = widget.serverUrl.replaceFirst('http://', 'ws://');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
        _connectionStatus = 'Connected';
      });

      // Subscribe to game updates
      _channel!.sink.add(jsonEncode({
        'action': 'subscribe',
        'gameId': _currentGameData!['id'],
      }));

      // Listen for updates
      _channel!.stream.listen(
        (data) {
          final message = jsonDecode(data);
          if (message['action'] == 'game_update' && message['game'] != null) {
            setState(() {
              _currentGameData = message['game'];
            });
          }
        },
        onDone: () {
          setState(() {
            _isConnected = false;
            _connectionStatus = 'Disconnected';
          });
        },
        onError: (error) {
          setState(() {
            _isConnected = false;
            _connectionStatus = 'Connection Error';
          });
        },
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Failed to Connect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${_currentGameData?['name'] ?? 'Unknown Game'} - Spectator',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        elevation: 0,
        actions: [
          _buildConnectionIndicator(theme),
        ],
      ),
      body: _currentGameData == null
          ? _buildLoadingView(theme)
          : _buildGameView(theme),
    );
  }

  Widget _buildConnectionIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green[600] : Colors.red[600],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isConnected ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _connectionStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading game data...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(ThemeData theme) {
    final players =
        (_currentGameData!['players'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final rounds =
        (_currentGameData!['rounds'] as List?)?.cast<Map<String, dynamic>>() ??
            [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGameInfoCard(theme),
          const SizedBox(height: 16),
          _buildPlayersCard(theme, players),
          const SizedBox(height: 16),
          _buildRoundsCard(theme, rounds),
          const SizedBox(height: 16),
          _buildScoreboardCard(theme, players, rounds),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Information',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                theme,
                'Status',
                (_currentGameData!['state'] ?? 'Unknown')
                    .toString()
                    .toUpperCase()),
            _buildInfoRow(theme, 'Current Round',
                '${(_currentGameData!['currentRoundIndex'] ?? 0) + 1}'),
            _buildInfoRow(theme, 'Total Rounds',
                '${(_currentGameData!['rounds'] as List?)?.length ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersCard(
      ThemeData theme, List<Map<String, dynamic>> players) {
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Players (${players.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...players
                .map((player) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              (player['name'] ?? '?')
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              player['name'] ?? 'Unknown Player',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundsCard(ThemeData theme, List<Map<String, dynamic>> rounds) {
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rounds (${rounds.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (rounds.isEmpty)
              Text(
                'No rounds yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...rounds.asMap().entries.map((entry) {
                final index = entry.key;
                final round = entry.value;
                final isCurrentRound =
                    index == (_currentGameData!['currentRoundIndex'] ?? 0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentRound
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrentRound
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Round ${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isCurrentRound
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                          fontWeight: isCurrentRound ? FontWeight.bold : null,
                        ),
                      ),
                      Text(
                        '${round['cards'] ?? 0} cards',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCurrentRound
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboardCard(ThemeData theme,
      List<Map<String, dynamic>> players, List<Map<String, dynamic>> rounds) {
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Scoreboard',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scores update automatically',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // This would show a live scoreboard
            // For now, just show a placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.leaderboard,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Live scoreboard coming soon',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
