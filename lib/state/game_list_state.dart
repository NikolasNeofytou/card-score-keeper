// lib/state/game_list_state.dart
import '../domain/models/game.dart';

/// Represents the state of multiple games in the application
class GameListState {
  final List<GameInfo> games;
  final String? currentGameId;
  final bool isLoading;
  final String? error;

  const GameListState({
    this.games = const [],
    this.currentGameId,
    this.isLoading = false,
    this.error,
  });

  GameListState copyWith({
    List<GameInfo>? games,
    String? currentGameId,
    bool? isLoading,
    String? error,
  }) =>
      GameListState(
        games: games ?? this.games,
        currentGameId: currentGameId ?? this.currentGameId,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  GameInfo? get currentGame {
    if (currentGameId == null) return null;
    for (final game in games) {
      if (game.id == currentGameId) return game;
    }
    return null;
  }

  List<GameInfo> get activeGames =>
      games.where((g) => g.status == GameStatus.active).toList();

  List<GameInfo> get archivedGames =>
      games.where((g) => g.status == GameStatus.archived).toList();
}

/// Lightweight game information for listing
class GameInfo {
  final String id;
  final String? name;
  final DateTime createdAt;
  final DateTime lastModified;
  final GameStatus status;
  final int playerCount;
  final int currentRound;
  final int totalRounds;
  final List<String> playerNames;

  const GameInfo({
    required this.id,
    this.name,
    required this.createdAt,
    required this.lastModified,
    required this.status,
    required this.playerCount,
    required this.currentRound,
    required this.totalRounds,
    required this.playerNames,
  });

  factory GameInfo.fromGame(Game game) {
    return GameInfo(
      id: game.id,
      name: game.name,
      createdAt: game.createdAt,
      lastModified: game.lastModified,
      status: game.state == GameState.finished
          ? GameStatus.completed
          : GameStatus.active,
      playerCount: game.players.length,
      currentRound: game.currentRoundIndex + 1,
      totalRounds: game.rounds.length,
      playerNames: game.players.map((p) => p.name).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
        'status': status.name,
        'playerCount': playerCount,
        'currentRound': currentRound,
        'totalRounds': totalRounds,
        'playerNames': playerNames,
      };

  factory GameInfo.fromJson(Map<String, dynamic> json) => GameInfo(
        id: json['id'] as String,
        name: json['name'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastModified: DateTime.parse(json['lastModified'] as String),
        status: GameStatus.values.byName(json['status'] as String),
        playerCount: json['playerCount'] as int,
        currentRound: json['currentRound'] as int,
        totalRounds: json['totalRounds'] as int,
        playerNames: (json['playerNames'] as List).cast<String>(),
      );
}

enum GameStatus { active, completed, archived }
