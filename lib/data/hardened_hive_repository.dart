// lib/data/hardened_hive_repository.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/game.dart';
import '../state/game_list_state.dart';
import 'game_repository.dart';
import 'persistence/storage_models.dart';
import 'persistence/migration_manager.dart';
import 'persistence/corruption_recovery.dart';

class HardenedHiveRepository implements GameRepository {
  static const _boxName = 'app_v2';
  static const _keyLastGameId = 'last_game_id';
  static const _keyGameListVersion = 'game_list_v2';
  static const _keyGamesPrefix = 'game_';

  Box? _cachedBox;
  bool _initialized = false;

  /// Initialize the repository with TypeAdapters and migrations
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Register TypeAdapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(StoredGameAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StoredGameSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(StoredPlayerAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(StoredGameRoundAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(StoredRoundEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(StoredGameInfoAdapter());
      }

      // Open box and run migrations
      final box = await Hive.openBox(_boxName);
      _cachedBox = box;

      // Run migration if needed
      await MigrationManager.migrate(box);

      // Validate data integrity
      final isValid = await MigrationManager.validateDataIntegrity(box);
      if (!isValid) {
        print('WARNING: Data integrity validation failed');
      }

      _initialized = true;
      print('HardenedHiveRepository initialized successfully');
    } catch (e) {
      print('Failed to initialize HardenedHiveRepository: $e');
      throw Exception('Repository initialization failed: $e');
    }
  }

  Future<Box> _box() async {
    if (!_initialized) {
      await initialize();
    }
    return _cachedBox ?? await Hive.openBox(_boxName);
  }

  @override
  Future<Game?> loadLastGame() async {
    try {
      final box = await _box();
      final gameId = box.get(_keyLastGameId) as String?;
      if (gameId == null || gameId.isEmpty) return null;

      return await loadGame(gameId);
    } catch (e) {
      print('Error loading last game: $e');
      return null;
    }
  }

  @override
  Future<void> saveLastGame(Game game) async {
    try {
      final box = await _box();
      await saveGame(game); // Ensure the game is saved first
      await box.put(_keyLastGameId, game.id);
    } catch (e) {
      print('Error saving last game: $e');
      throw Exception('Failed to save last game: $e');
    }
  }

  @override
  Future<void> clearLastGame() async {
    try {
      final box = await _box();
      await box.delete(_keyLastGameId);
    } catch (e) {
      print('Error clearing last game: $e');
    }
  }

  @override
  Future<List<Game>> loadAllGames() async {
    try {
      final gameList = await loadGameList();
      final games = <Game>[];

      for (final info in gameList) {
        final game = await loadGame(info.id);
        if (game != null) {
          games.add(game);
        } else {
          print('Warning: Could not load game ${info.id}');
        }
      }

      return games;
    } catch (e) {
      print('Error loading all games: $e');
      return [];
    }
  }

  @override
  Future<Game?> loadGame(String gameId) async {
    try {
      final box = await _box();
      final gameKey = '$_keyGamesPrefix$gameId';

      // Try to load as TypeAdapter format first
      final storedGame = box.get(gameKey) as StoredGame?;
      if (storedGame != null) {
        try {
          return storedGame.toGame();
        } catch (e) {
          print('Error converting stored game $gameId: $e');

          // Try corruption recovery
          final recovered = await CorruptionRecovery.recoverGame(gameId, box);
          if (recovered != null) {
            // Save the recovered game in the new format
            await saveGame(recovered);
            return recovered;
          }
        }
      }

      // Fallback to legacy JSON format
      final jsonStr = box.get(gameKey) as String?;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          final game = Game.fromJson(json);

          // Migrate to new format
          await saveGame(game);
          return game;
        } catch (e) {
          print('Error parsing legacy JSON for game $gameId: $e');

          // Try corruption recovery
          final recovered = await CorruptionRecovery.recoverGame(gameId, box);
          return recovered;
        }
      }

      return null;
    } catch (e) {
      print('Error loading game $gameId: $e');
      return null;
    }
  }

  @override
  Future<void> saveGame(Game game) async {
    try {
      final box = await _box();

      // Save as TypeAdapter format with corruption safeguards
      final storedGame = StoredGame.fromGame(game);
      await box.put('$_keyGamesPrefix${game.id}', storedGame);

      // Update game list
      await _updateGameList(game);

      print('Successfully saved game ${game.id}');
    } catch (e) {
      print('Error saving game ${game.id}: $e');
      throw Exception('Failed to save game: $e');
    }
  }

  @override
  Future<void> deleteGame(String gameId) async {
    try {
      final box = await _box();
      await box.delete('$_keyGamesPrefix$gameId');

      // Update game list
      final gameList = await loadGameList();
      gameList.removeWhere((g) => g.id == gameId);
      await saveGameList(gameList);

      // Clear last game if it was deleted
      final lastGameId = box.get(_keyLastGameId) as String?;
      if (lastGameId == gameId) {
        await box.delete(_keyLastGameId);
      }

      print('Successfully deleted game $gameId');
    } catch (e) {
      print('Error deleting game $gameId: $e');
      throw Exception('Failed to delete game: $e');
    }
  }

  @override
  Future<void> saveGameList(List<GameInfo> games) async {
    try {
      final box = await _box();

      // Save as both TypeAdapter and JSON for redundancy
      final storedInfoList =
          games.map((g) => StoredGameInfo.fromGameInfo(g)).toList();

      await box.put(_keyGameListVersion, storedInfoList);

      // Also save as JSON backup
      final jsonBackup = jsonEncode(games.map((g) => g.toJson()).toList());
      await box.put('${_keyGameListVersion}_json_backup', jsonBackup);
    } catch (e) {
      print('Error saving game list: $e');
      throw Exception('Failed to save game list: $e');
    }
  }

  @override
  Future<List<GameInfo>> loadGameList() async {
    try {
      final box = await _box();

      // Try TypeAdapter format first
      final storedListRaw = box.get(_keyGameListVersion);
      if (storedListRaw != null) {
        try {
          List<StoredGameInfo> storedList = [];
          if (storedListRaw is List<StoredGameInfo>) {
            storedList = storedListRaw;
          } else if (storedListRaw is List) {
            // Handle List<dynamic> case - try to cast each item individually
            for (final item in storedListRaw) {
              if (item is StoredGameInfo) {
                storedList.add(item);
              }
            }
          }

          if (storedList.isNotEmpty) {
            return storedList.map((stored) => stored.toGameInfo()).toList();
          }
        } catch (e) {
          print('Error converting stored game list: $e');
          // Clear corrupted data
          await box.delete(_keyGameListVersion);
        }
      }

      // Fallback to JSON backup
      final jsonStr = box.get('${_keyGameListVersion}_json_backup') as String?;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final jsonList = jsonDecode(jsonStr) as List;
          return jsonList
              .map((json) => GameInfo.fromJson(json as Map<String, dynamic>))
              .toList();
        } catch (e) {
          print('Error parsing game list JSON backup: $e');
        }
      }

      // Fallback to scanning individual games
      return await _rebuildGameListFromScan(box);
    } catch (e) {
      print('Error loading game list: $e');
      return [];
    }
  }

  Future<void> _updateGameList(Game game) async {
    final gameList = await loadGameList();
    final existingIndex = gameList.indexWhere((g) => g.id == game.id);
    final gameInfo = GameInfo.fromGame(game);

    if (existingIndex >= 0) {
      gameList[existingIndex] = gameInfo;
    } else {
      gameList.add(gameInfo);
    }

    await saveGameList(gameList);
  }

  Future<List<GameInfo>> _rebuildGameListFromScan(Box box) async {
    print('Rebuilding game list from individual games...');
    final gameList = <GameInfo>[];

    for (final key in box.keys) {
      if (key.toString().startsWith(_keyGamesPrefix)) {
        final gameId = key.toString().substring(_keyGamesPrefix.length);
        try {
          final game = await loadGame(gameId);
          if (game != null) {
            gameList.add(GameInfo.fromGame(game));
          }
        } catch (e) {
          print('Error scanning game $gameId: $e');
        }
      }
    }

    // Save the rebuilt list
    await saveGameList(gameList);
    return gameList;
  }

  /// Perform a health check on the storage system
  Future<StorageHealthReport> performHealthCheck() async {
    try {
      final box = await _box();
      return await CorruptionRecovery.performHealthCheck(box);
    } catch (e) {
      print('Error performing health check: $e');
      final report = StorageHealthReport();
      report.issuesFound.add('Health check failed: $e');
      return report;
    }
  }

  /// Force a data integrity check and repair
  Future<void> repairStorage() async {
    try {
      print('Starting storage repair...');
      final box = await _box();

      // Perform health check
      final report = await performHealthCheck();
      print('Health check report:');
      print(report.toString());

      if (report.isHealthy) {
        print('Storage is healthy, no repair needed');
        return;
      }

      // Attempt to repair corrupted games
      final corruptedCount = report.corruptedGames;
      int repairedCount = 0;

      for (final key in box.keys) {
        if (key.toString().startsWith(_keyGamesPrefix)) {
          final gameId = key.toString().substring(_keyGamesPrefix.length);
          final game = await loadGame(gameId);
          if (game != null) {
            // Re-save the game to ensure it's in the correct format
            await saveGame(game);
            repairedCount++;
          }
        }
      }

      // Rebuild game list
      await _rebuildGameListFromScan(box);

      print('Storage repair completed: $repairedCount games processed');
    } catch (e) {
      print('Storage repair failed: $e');
      throw Exception('Failed to repair storage: $e');
    }
  }
}
