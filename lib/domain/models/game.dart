// lib/domain/models/game.dart
import 'player.dart';
import 'round.dart';

enum GameState { prediction, scoring, finished }

class GameSettings {
  final int peakCards;
  final int bonusExact;

  const GameSettings({required this.peakCards, required this.bonusExact});

  Map<String, dynamic> toJson() => {
        'peakCards': peakCards,
        'bonusExact': bonusExact,
      };

  static GameSettings fromJson(Map<String, dynamic> json) => GameSettings(
        peakCards: json['peakCards'] as int,
        bonusExact: json['bonusExact'] as int,
      );
}

class Game {
  final String id;
  final String? name;
  final GameSettings settings;
  final List<Player> players;
  final List<GameRound> rounds;
  final int currentRoundIndex;
  final GameState state;
  final DateTime createdAt;
  final DateTime lastModified;

  const Game({
    required this.id,
    required this.name,
    required this.settings,
    required this.players,
    required this.rounds,
    required this.currentRoundIndex,
    required this.state,
    required this.createdAt,
    required this.lastModified,
  });

  Game copyWith({
    String? name,
    GameSettings? settings,
    List<Player>? players,
    List<GameRound>? rounds,
    int? currentRoundIndex,
    GameState? state,
    DateTime? createdAt,
    DateTime? lastModified,
  }) =>
      Game(
        id: id,
        name: name ?? this.name,
        settings: settings ?? this.settings,
        players: players ?? this.players,
        rounds: rounds ?? this.rounds,
        currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
        state: state ?? this.state,
        createdAt: createdAt ?? this.createdAt,
        lastModified: lastModified ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'settings': settings.toJson(),
        'players': players.map((p) => p.toJson()).toList(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'currentRoundIndex': currentRoundIndex,
        'state': state.name,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
      };

  static Game fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Game(
      id: json['id'] as String,
      name: json['name'] as String?,
      settings: GameSettings.fromJson(json['settings'] as Map<String, dynamic>),
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as List)
          .map((r) => GameRound.fromJson(r as Map<String, dynamic>))
          .toList(),
      currentRoundIndex: json['currentRoundIndex'] as int,
      state: GameState.values.firstWhere((s) => s.name == json['state']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : now,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : now,
    );
  }
}
