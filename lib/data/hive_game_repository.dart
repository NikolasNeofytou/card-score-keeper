// lib/data/hive_game_repository.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/game.dart';
import '../state/game_list_state.dart';
import 'game_repository.dart';

class HiveGameRepository implements GameRepository {
  static const _boxName = 'app';
  static const _keyLastGame = 'last_game_json';
  static const _keyGameList = 'game_list_json';
  static const _keyGamesPrefix = 'game_';

  Future<Box> _box() async => Hive.openBox(_boxName);

  @override
  Future<Game?> loadLastGame() async {
    final box = await _box();
    final jsonStr = box.get(_keyLastGame) as String?;
    if (jsonStr == null || jsonStr.isEmpty) return null;
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return Game.fromJson(map);
  }

  @override
  Future<void> saveLastGame(Game game) async {
    final box = await _box();
    final jsonStr = jsonEncode(game.toJson());
    await box.put(_keyLastGame, jsonStr);
  }

  @override
  Future<void> clearLastGame() async {
    final box = await _box();
    await box.delete(_keyLastGame);
  }

  @override
  Future<List<Game>> loadAllGames() async {
    final box = await _box();
    final gameList = await loadGameList();
    final games = <Game>[];
    
    for (final info in gameList) {
      final game = await loadGame(info.id);
      if (game != null) games.add(game);
    }
    
    return games;
  }

  @override
  Future<Game?> loadGame(String gameId) async {
    final box = await _box();
    final jsonStr = box.get('$_keyGamesPrefix$gameId') as String?;
    if (jsonStr == null || jsonStr.isEmpty) return null;
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return Game.fromJson(map);
  }

  @override
  Future<void> saveGame(Game game) async {
    final box = await _box();
    final jsonStr = jsonEncode(game.toJson());
    await box.put('$_keyGamesPrefix${game.id}', jsonStr);
    
    // Update game list
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

  @override
  Future<void> deleteGame(String gameId) async {
    final box = await _box();
    await box.delete('$_keyGamesPrefix$gameId');
    
    // Update game list
    final gameList = await loadGameList();
    gameList.removeWhere((g) => g.id == gameId);
    await saveGameList(gameList);
  }

  @override
  Future<void> saveGameList(List<GameInfo> games) async {
    final box = await _box();
    final jsonList = games.map((g) => g.toJson()).toList();
    final jsonStr = jsonEncode(jsonList);
    await box.put(_keyGameList, jsonStr);
  }

  @override
  Future<List<GameInfo>> loadGameList() async {
    final box = await _box();
    final jsonStr = box.get(_keyGameList) as String?;
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final jsonList = jsonDecode(jsonStr) as List;
    return jsonList.map((json) => GameInfo.fromJson(json as Map<String, dynamic>)).toList();
  }
}
