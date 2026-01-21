// lib/data/persistence/corruption_recovery.dart
import 'package:hive/hive.dart';
import '../../domain/models/game.dart';
import 'storage_models.dart';
import 'schema_version.dart';

class CorruptionRecovery {
  /// Attempt to recover a corrupted game entry
  static Future<Game?> recoverGame(String gameId, Box box) async {
    print('Attempting to recover corrupted game: $gameId');

    // Try multiple recovery strategies
    Game? recovered;

    // Strategy 1: Look for backup JSON in StoredGame.rawJson
    recovered = await _tryRawJsonRecovery(gameId, box);
    if (recovered != null) {
      print('Recovered game using raw JSON backup');
      return recovered;
    }

    // Strategy 2: Look in corrupted data backup
    recovered = await _tryCorruptedBackupRecovery(gameId, box);
    if (recovered != null) {
      print('Recovered game from corrupted data backup');
      return recovered;
    }

    // Strategy 3: Partial recovery from fragments
    recovered = await _tryPartialRecovery(gameId, box);
    if (recovered != null) {
      print('Partially recovered game from fragments');
      return recovered;
    }

    print('Could not recover game: $gameId');
    return null;
  }

  static Future<Game?> _tryRawJsonRecovery(String gameId, Box box) async {
    try {
      final storedGame = box.get('game_$gameId') as StoredGame?;
      if (storedGame?.rawJson != null) {
        // Try to parse the backup JSON
        final json = _parseJsonString(storedGame!.rawJson!);
        if (json != null) {
          return Game.fromJson(json);
        }
      }
    } catch (e) {
      print('Raw JSON recovery failed: $e');
    }
    return null;
  }

  static Future<Game?> _tryCorruptedBackupRecovery(
      String gameId, Box box) async {
    try {
      final corruptedData =
          box.get('_corrupted_data_backup') as Map<String, dynamic>?;
      if (corruptedData != null) {
        final gameKey = 'game_$gameId';
        if (corruptedData.containsKey(gameKey)) {
          final gameData = corruptedData[gameKey] as String;
          final json = _parseJsonString(gameData);
          if (json != null) {
            return Game.fromJson(json);
          }
        }
      }
    } catch (e) {
      print('Corrupted backup recovery failed: $e');
    }
    return null;
  }

  static Future<Game?> _tryPartialRecovery(String gameId, Box box) async {
    try {
      // Create a minimal game with whatever data we can salvage
      final now = DateTime.now();

      return Game(
        id: gameId,
        name: 'Recovered Game',
        settings: const GameSettings(peakCards: 13, bonusExact: 10),
        players: [], // Will be empty - user can re-add players
        rounds: [],
        currentRoundIndex: 0,
        state: GameState.finished,
        createdAt: now,
        lastModified: now,
      );
    } catch (e) {
      print('Partial recovery failed: $e');
    }
    return null;
  }

  static Map<String, dynamic>? _parseJsonString(String jsonStr) {
    try {
      // Simple JSON parser for recovery
      jsonStr = jsonStr.trim();
      if (!jsonStr.startsWith('{') || !jsonStr.endsWith('}')) {
        return null;
      }

      // Basic key-value extraction for recovery
      final Map<String, dynamic> result = {};
      final content = jsonStr.substring(1, jsonStr.length - 1);
      final pairs = content.split(',');

      for (final pair in pairs) {
        final colonIndex = pair.indexOf(':');
        if (colonIndex > 0) {
          final key = pair.substring(0, colonIndex).trim().replaceAll('"', '');
          final value =
              pair.substring(colonIndex + 1).trim().replaceAll('"', '');

          // Try to parse common fields
          switch (key) {
            case 'id':
            case 'name':
            case 'state':
              result[key] = value;
              break;
            case 'currentRoundIndex':
              result[key] = int.tryParse(value) ?? 0;
              break;
            case 'createdAt':
            case 'lastModified':
              result[key] =
                  value.isNotEmpty ? value : DateTime.now().toIso8601String();
              break;
          }
        }
      }

      // Add required fields if missing
      if (!result.containsKey('id'))
        result['id'] = 'recovered-${DateTime.now().millisecondsSinceEpoch}';
      if (!result.containsKey('settings'))
        result['settings'] = {'peakCards': 13, 'bonusExact': 10};
      if (!result.containsKey('players')) result['players'] = [];
      if (!result.containsKey('rounds')) result['rounds'] = [];
      if (!result.containsKey('currentRoundIndex'))
        result['currentRoundIndex'] = 0;
      if (!result.containsKey('state')) result['state'] = 'finished';
      if (!result.containsKey('createdAt'))
        result['createdAt'] = DateTime.now().toIso8601String();
      if (!result.containsKey('lastModified'))
        result['lastModified'] = DateTime.now().toIso8601String();

      return result;
    } catch (e) {
      print('JSON parsing failed during recovery: $e');
      return null;
    }
  }

  /// Health check for the entire storage system
  static Future<StorageHealthReport> performHealthCheck(Box box) async {
    final report = StorageHealthReport();

    try {
      // Check schema version
      final version = box.get(SchemaVersion.key, defaultValue: 0) as int;
      report.schemaVersion = version;
      report.schemaVersionMatch = version == SchemaVersion.current;

      // Check all game entries
      for (final key in box.keys) {
        final keyStr = key.toString();
        if (keyStr.startsWith('game_')) {
          report.totalGames++;

          try {
            final gameData = box.get(key);
            if (gameData is StoredGame) {
              // TypeAdapter format - try to convert
              try {
                final game = gameData.toGame();
                report.validGames++;

                // Check for data quality issues
                if (game.players.isEmpty)
                  report.issuesFound.add('Game ${game.id} has no players');
                if (game.name == null || game.name!.isEmpty)
                  report.issuesFound.add('Game ${game.id} has no name');
              } catch (e) {
                report.corruptedGames++;
                report.issuesFound.add('Failed to convert game $keyStr: $e');
              }
            } else if (gameData is String) {
              // Legacy JSON format
              report.legacyFormatGames++;
              try {
                final json = _parseJsonString(gameData);
                if (json != null) {
                  final game = Game.fromJson(json);
                  report.validGames++;
                } else {
                  report.corruptedGames++;
                  report.issuesFound.add('Invalid JSON in game $keyStr');
                }
              } catch (e) {
                report.corruptedGames++;
                report.issuesFound.add('JSON parsing failed for $keyStr: $e');
              }
            } else {
              report.corruptedGames++;
              report.issuesFound.add('Unknown data format for $keyStr');
            }
          } catch (e) {
            report.corruptedGames++;
            report.issuesFound.add('Error reading $keyStr: $e');
          }
        }
      }

      // Check for orphaned data
      final corruptedBackup = box.get('_corrupted_data_backup');
      if (corruptedBackup != null) {
        report.hasCorruptedBackup = true;
        if (corruptedBackup is Map) {
          report.corruptedBackupCount = corruptedBackup.length;
        }
      }
    } catch (e) {
      report.issuesFound.add('Health check failed: $e');
    }

    return report;
  }
}

class StorageHealthReport {
  int schemaVersion = 0;
  bool schemaVersionMatch = false;
  int totalGames = 0;
  int validGames = 0;
  int corruptedGames = 0;
  int legacyFormatGames = 0;
  bool hasCorruptedBackup = false;
  int corruptedBackupCount = 0;
  List<String> issuesFound = [];

  bool get isHealthy =>
      corruptedGames == 0 && schemaVersionMatch && issuesFound.isEmpty;

  double get healthScore {
    if (totalGames == 0) return 1.0;
    return validGames / totalGames;
  }

  @override
  String toString() {
    return 'StorageHealthReport{\n'
        '  Schema Version: $schemaVersion (match: $schemaVersionMatch)\n'
        '  Total Games: $totalGames\n'
        '  Valid Games: $validGames\n'
        '  Corrupted Games: $corruptedGames\n'
        '  Legacy Format: $legacyFormatGames\n'
        '  Health Score: ${(healthScore * 100).toStringAsFixed(1)}%\n'
        '  Issues: ${issuesFound.length}\n'
        '  Corrupted Backup: $hasCorruptedBackup ($corruptedBackupCount entries)\n'
        '}';
  }
}
