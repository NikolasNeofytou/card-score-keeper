// lib/data/game_repository.dart
import '../domain/models/game.dart';
import '../state/game_list_state.dart';

abstract class GameRepository {
  Future<Game?> loadLastGame();
  Future<void> saveLastGame(Game game);
  Future<void> clearLastGame();
  
  // Multiple game management
  Future<List<Game>> loadAllGames();
  Future<Game?> loadGame(String gameId);
  Future<void> saveGame(Game game);
  Future<void> deleteGame(String gameId);
  Future<void> saveGameList(List<GameInfo> games);
  Future<List<GameInfo>> loadGameList();
}
