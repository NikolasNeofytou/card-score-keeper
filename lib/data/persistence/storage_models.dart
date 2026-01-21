// lib/data/persistence/storage_models.dart
import 'package:hive/hive.dart';
import '../../domain/models/game.dart';
import '../../domain/models/player.dart';
import '../../domain/models/round.dart';
import '../../state/game_list_state.dart';
import 'schema_version.dart';

part 'storage_models.g.dart';

/// Storage wrapper for Game model with schema versioning
@HiveType(typeId: 0)
class StoredGame extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final StoredGameSettings settings;

  @HiveField(3)
  final List<StoredPlayer> players;

  @HiveField(4)
  final List<StoredGameRound> rounds;

  @HiveField(5)
  final int currentRoundIndex;

  @HiveField(6)
  final String state; // enum as string

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime lastModified;

  @HiveField(9, defaultValue: SchemaVersion.current)
  final int schemaVersion;

  @HiveField(10)
  final String? rawJson; // backup for migration/corruption recovery

  StoredGame({
    required this.id,
    this.name,
    required this.settings,
    required this.players,
    required this.rounds,
    required this.currentRoundIndex,
    required this.state,
    required this.createdAt,
    required this.lastModified,
    this.schemaVersion = SchemaVersion.current,
    this.rawJson,
  });

  factory StoredGame.fromGame(Game game) {
    return StoredGame(
      id: game.id,
      name: game.name,
      settings: StoredGameSettings.fromGameSettings(game.settings),
      players: game.players.map((p) => StoredPlayer.fromPlayer(p)).toList(),
      rounds: game.rounds.map((r) => StoredGameRound.fromGameRound(r)).toList(),
      currentRoundIndex: game.currentRoundIndex,
      state: game.state.name,
      createdAt: game.createdAt,
      lastModified: game.lastModified,
      schemaVersion: SchemaVersion.current,
      rawJson: game.toJson().toString(), // backup
    );
  }

  Game toGame() {
    try {
      return Game(
        id: id,
        name: name,
        settings: settings.toGameSettings(),
        players: players.map((p) => p.toPlayer()).toList(),
        rounds: rounds.map((r) => r.toGameRound()).toList(),
        currentRoundIndex: currentRoundIndex,
        state: GameState.values.firstWhere((s) => s.name == state),
        createdAt: createdAt,
        lastModified: lastModified,
      );
    } catch (e) {
      // Fallback to raw JSON if structured data is corrupted
      if (rawJson != null) {
        try {
          final Map<String, dynamic> json = Map<String, dynamic>.from(
              rawJson!.contains('{')
                  ? _parseJson(rawJson!)
                  : {'error': 'Invalid JSON format'});
          return Game.fromJson(json);
        } catch (_) {
          // If all else fails, create a minimal game
          return _createCorruptedGameFallback();
        }
      }
      return _createCorruptedGameFallback();
    }
  }

  Game _createCorruptedGameFallback() {
    final now = DateTime.now();
    return Game(
      id: id,
      name: name ?? 'Corrupted Game',
      settings: const GameSettings(peakCards: 13, bonusExact: 10),
      players: [],
      rounds: [],
      currentRoundIndex: 0,
      state: GameState.finished,
      createdAt: createdAt,
      lastModified: now,
    );
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    // Simple JSON parser fallback
    try {
      return Map<String, dynamic>.from(
          jsonStr.split(',').fold<Map<String, dynamic>>({}, (map, pair) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          map[parts[0].trim().replaceAll('"', '')] =
              parts[1].trim().replaceAll('"', '');
        }
        return map;
      }));
    } catch (e) {
      return {'error': 'Failed to parse JSON: $e'};
    }
  }
}

/// Storage wrapper for GameSettings
@HiveType(typeId: 1)
class StoredGameSettings {
  @HiveField(0)
  final int peakCards;

  @HiveField(1)
  final int bonusExact;

  @HiveField(2, defaultValue: SchemaVersion.current)
  final int schemaVersion;

  StoredGameSettings({
    required this.peakCards,
    required this.bonusExact,
    this.schemaVersion = SchemaVersion.current,
  });

  factory StoredGameSettings.fromGameSettings(GameSettings settings) {
    return StoredGameSettings(
      peakCards: settings.peakCards,
      bonusExact: settings.bonusExact,
    );
  }

  GameSettings toGameSettings() {
    return GameSettings(
      peakCards: peakCards,
      bonusExact: bonusExact,
    );
  }
}

/// Storage wrapper for Player
@HiveType(typeId: 2)
class StoredPlayer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2, defaultValue: SchemaVersion.current)
  final int schemaVersion;

  StoredPlayer({
    required this.id,
    required this.name,
    this.schemaVersion = SchemaVersion.current,
  });

  factory StoredPlayer.fromPlayer(Player player) {
    return StoredPlayer(
      id: player.id,
      name: player.name,
    );
  }

  Player toPlayer() {
    return Player(
      id: id,
      name: name,
    );
  }
}

/// Storage wrapper for GameRound
@HiveType(typeId: 3)
class StoredGameRound {
  @HiveField(0)
  final int index;

  @HiveField(1)
  final int cards;

  @HiveField(2)
  final String status; // RoundStatus as string

  @HiveField(3)
  final List<StoredRoundEntry> entries;

  @HiveField(4, defaultValue: SchemaVersion.current)
  final int schemaVersion;

  StoredGameRound({
    required this.index,
    required this.cards,
    required this.status,
    required this.entries,
    this.schemaVersion = SchemaVersion.current,
  });

  factory StoredGameRound.fromGameRound(GameRound round) {
    return StoredGameRound(
      index: round.index,
      cards: round.cards,
      status: round.status.name,
      entries:
          round.entries.map((e) => StoredRoundEntry.fromRoundEntry(e)).toList(),
    );
  }

  GameRound toGameRound() {
    return GameRound(
      index: index,
      cards: cards,
      status: RoundStatus.values.firstWhere((s) => s.name == status),
      entries: entries.map((e) => e.toRoundEntry()).toList(),
    );
  }
}

/// Storage wrapper for RoundEntry
@HiveType(typeId: 4)
class StoredRoundEntry {
  @HiveField(0)
  final String playerId;

  @HiveField(1)
  final int? predictedWins;

  @HiveField(2)
  final int? actualWins;

  @HiveField(3, defaultValue: SchemaVersion.current)
  final int schemaVersion;

  StoredRoundEntry({
    required this.playerId,
    this.predictedWins,
    this.actualWins,
    this.schemaVersion = SchemaVersion.current,
  });

  factory StoredRoundEntry.fromRoundEntry(RoundEntry entry) {
    return StoredRoundEntry(
      playerId: entry.playerId,
      predictedWins: entry.predictedWins,
      actualWins: entry.actualWins,
    );
  }

  RoundEntry toRoundEntry() {
    return RoundEntry(
      playerId: playerId,
      predictedWins: predictedWins,
      actualWins: actualWins,
    );
  }
}

/// Storage wrapper for GameInfo
@HiveType(typeId: 5)
class StoredGameInfo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime lastModified;

  @HiveField(4)
  final String status; // GameStatus as string

  @HiveField(5)
  final int playerCount;

  @HiveField(6)
  final int currentRound;

  @HiveField(7)
  final int totalRounds;

  @HiveField(8)
  final List<String> playerNames;

  @HiveField(9, defaultValue: SchemaVersion.current)
  final int schemaVersion;

  StoredGameInfo({
    required this.id,
    this.name,
    required this.createdAt,
    required this.lastModified,
    required this.status,
    required this.playerCount,
    required this.currentRound,
    required this.totalRounds,
    required this.playerNames,
    this.schemaVersion = SchemaVersion.current,
  });

  factory StoredGameInfo.fromGameInfo(GameInfo gameInfo) {
    return StoredGameInfo(
      id: gameInfo.id,
      name: gameInfo.name,
      createdAt: gameInfo.createdAt,
      lastModified: gameInfo.lastModified,
      status: gameInfo.status.name,
      playerCount: gameInfo.playerCount,
      currentRound: gameInfo.currentRound,
      totalRounds: gameInfo.totalRounds,
      playerNames: gameInfo.playerNames,
    );
  }

  GameInfo toGameInfo() {
    return GameInfo(
      id: id,
      name: name,
      createdAt: createdAt,
      lastModified: lastModified,
      status: GameStatus.values.byName(status),
      playerCount: playerCount,
      currentRound: currentRound,
      totalRounds: totalRounds,
      playerNames: playerNames,
    );
  }
}
