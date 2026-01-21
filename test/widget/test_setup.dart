// Test setup utilities for widget tests
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../lib/data/game_repository.dart';
import '../../lib/domain/models/game.dart';
import '../../lib/domain/models/player.dart';
import '../../lib/domain/models/round.dart';
import '../../lib/state/game_list_state.dart';
import '../../lib/state/providers.dart';
import 'fake_path_provider.dart';

/// Sets up test environment with proper Hive initialization
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup fake path provider
  PathProviderPlatform.instance = FakePathProvider();

  // Initialize Hive with test directory
  Hive.init('/tmp/test_hive');
}

/// Cleans up test environment
Future<void> cleanupTestEnvironment() async {
  try {
    await Hive.close();
  } catch (e) {
    // Ignore cleanup errors
  }
}

/// Creates a test app with proper providers and test data
Widget createTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: [
      // Override the repository provider to use in-memory data
      gameRepositoryProvider.overrideWith((ref) => TestGameRepository()),
      ...?overrides,
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Test implementation of game repository that doesn't require Hive
class TestGameRepository extends GameRepository {
  final Map<String, Game> _games = {};
  Game? _lastGame;
  final List<GameInfo> _gameInfoList = [];

  @override
  Future<Game?> loadLastGame() async {
    return _lastGame;
  }

  @override
  Future<void> saveLastGame(Game game) async {
    _lastGame = game;
  }

  @override
  Future<void> clearLastGame() async {
    _lastGame = null;
  }

  @override
  Future<List<Game>> loadAllGames() async {
    return _games.values.toList();
  }

  @override
  Future<Game?> loadGame(String gameId) async {
    return _games[gameId];
  }

  @override
  Future<void> saveGame(Game game) async {
    _games[game.id] = game;
  }

  @override
  Future<void> deleteGame(String gameId) async {
    _games.remove(gameId);
    _gameInfoList.removeWhere((info) => info.id == gameId);
  }

  @override
  Future<void> saveGameList(List<GameInfo> games) async {
    _gameInfoList.clear();
    _gameInfoList.addAll(games);
  }

  @override
  Future<List<GameInfo>> loadGameList() async {
    return List.from(_gameInfoList);
  }
}
