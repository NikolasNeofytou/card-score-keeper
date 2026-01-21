// lib/state/game_list_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/game_repository.dart';
import 'game_list_state.dart';

class GameListController extends StateNotifier<GameListState> {
  final GameRepository _repository;
  final _uuid = const Uuid();

  GameListController(this._repository) : super(const GameListState()) {
    _loadGameList();
  }

  Future<void> _loadGameList() async {
    state = state.copyWith(isLoading: true);
    try {
      final games = await _repository.loadAllGames();
      final gameInfos = games.map((g) => GameInfo.fromGame(g)).toList();

      // Set current game to the last modified active game
      final activeGames = gameInfos
          .where((g) => g.status == GameStatus.active)
          .toList()
        ..sort((a, b) => b.lastModified.compareTo(a.lastModified));

      state = GameListState(
        games: gameInfos,
        currentGameId: activeGames.isNotEmpty ? activeGames.first.id : null,
        isLoading: false,
      );
    } catch (e) {
      state = GameListState(isLoading: false, error: e.toString());
    }
  }

  Future<void> switchToGame(String gameId) async {
    state = state.copyWith(currentGameId: gameId);
  }

  Future<void> archiveGame(String gameId) async {
    try {
      final updatedGames = state.games.map((game) {
        if (game.id == gameId) {
          // Create updated GameInfo with archived status
          return GameInfo(
            id: game.id,
            name: game.name,
            createdAt: game.createdAt,
            lastModified: DateTime.now(),
            status: GameStatus.archived,
            playerCount: game.playerCount,
            currentRound: game.currentRound,
            totalRounds: game.totalRounds,
            playerNames: game.playerNames,
          );
        }
        return game;
      }).toList();

      state = state.copyWith(games: updatedGames);

      // If archiving current game, switch to another active game
      if (state.currentGameId == gameId) {
        final activeGames = state.activeGames;
        state = state.copyWith(
          currentGameId: activeGames.isNotEmpty ? activeGames.first.id : null,
        );
      }

      await _saveGameList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      await _repository.deleteGame(gameId);

      final updatedGames = state.games.where((g) => g.id != gameId).toList();
      state = state.copyWith(games: updatedGames);

      // If deleting current game, switch to another
      if (state.currentGameId == gameId) {
        final activeGames = state.activeGames;
        state = state.copyWith(
          currentGameId: activeGames.isNotEmpty ? activeGames.first.id : null,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unarchiveGame(String gameId) async {
    try {
      final updatedGames = state.games.map((game) {
        if (game.id == gameId) {
          return GameInfo(
            id: game.id,
            name: game.name,
            createdAt: game.createdAt,
            lastModified: DateTime.now(),
            status: GameStatus.active,
            playerCount: game.playerCount,
            currentRound: game.currentRound,
            totalRounds: game.totalRounds,
            playerNames: game.playerNames,
          );
        }
        return game;
      }).toList();

      state = state.copyWith(games: updatedGames);
      await _saveGameList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _saveGameList() async {
    // Save game list metadata to repository
    await _repository.saveGameList(state.games);
  }

  Future<void> refreshGameList() async {
    await _loadGameList();
  }
}
