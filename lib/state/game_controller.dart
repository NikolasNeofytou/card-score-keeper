// lib/state/game_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/game_repository.dart';
import '../data/hive_game_repository.dart';
import '../domain/models/game.dart' as model;
import '../domain/models/player.dart';
import '../domain/models/round.dart';
import '../domain/logic/schedule.dart';
import '../domain/logic/validation.dart' as validation;
import 'game_state.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return HiveGameRepository();
});

final gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
  return GameController(ref.watch(gameRepositoryProvider));
});

class GameController extends StateNotifier<GameState> {
  final GameRepository _repository;
  final _uuid = const Uuid();

  GameController(this._repository) : super(const GameState()) {
    _loadLastGame();
  }

  Future<void> _loadLastGame() async {
    state = state.copyWith(isLoading: true);
    try {
      final game = await _repository.loadLastGame();
      state = GameState(currentGame: game, isLoading: false);
    } catch (e) {
      state = GameState(isLoading: false, error: e.toString());
    }
  }

  Future<void> createGame({
    required List<String> playerNames,
    required int peakCards,
    required int bonusExact,
    String? gameName,
  }) async {
    try {
      // Create players
      final players = playerNames
          .map((name) => Player(id: _uuid.v4(), name: name))
          .toList();

      // Build round schedule
      final schedule = buildRoundSchedule(peakCards);

      // Create rounds with empty entries
      final rounds = schedule.asMap().entries.map((entry) {
        final index = entry.key;
        final cards = entry.value;
        return GameRound(
          index: index,
          cards: cards,
          status: RoundStatus.empty,
          entries: players
              .map((p) => RoundEntry(playerId: p.id))
              .toList(),
        );
      }).toList();

      // Create game
      final game = model.Game(
        id: _uuid.v4(),
        name: gameName,
        settings: model.GameSettings(peakCards: peakCards, bonusExact: bonusExact),
        players: players,
        rounds: rounds,
        currentRoundIndex: 0,
        state: model.GameState.prediction,
      );

      // Save and update state
      await _repository.saveLastGame(game);
      state = GameState(currentGame: game);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> savePredictions(Map<String, int> predictions) async {
    final game = state.currentGame;
    if (game == null) return;

    try {
      final currentRound = game.rounds[game.currentRoundIndex];
      
      // Update entries with predictions
      final updatedEntries = currentRound.entries.map((entry) {
        return entry.copyWith(predictedWins: predictions[entry.playerId]);
      }).toList();

      // Update round
      final updatedRound = currentRound.copyWith(
        status: RoundStatus.predictionsSet,
        entries: updatedEntries,
      );

      // Update rounds list
      final updatedRounds = List<GameRound>.from(game.rounds);
      updatedRounds[game.currentRoundIndex] = updatedRound;

      // Update game
      final updatedGame = game.copyWith(
        rounds: updatedRounds,
        state: model.GameState.scoring,
      );

      await _repository.saveLastGame(updatedGame);
      state = GameState(currentGame: updatedGame);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  String? validateResults(Map<String, int> actualWins) {
    final game = state.currentGame;
    if (game == null) return 'No active game';

    final currentRound = game.rounds[game.currentRoundIndex];
    return validation.validateResults(
      cardsThisRound: currentRound.cards,
      actualWinsByPlayerId: actualWins,
    );
  }

  Future<void> saveResults(Map<String, int> actualWins) async {
    final game = state.currentGame;
    if (game == null) return;

    try {
      final currentRound = game.rounds[game.currentRoundIndex];

      // Validate
      final error = validation.validateResults(
        cardsThisRound: currentRound.cards,
        actualWinsByPlayerId: actualWins,
      );
      if (error != null) {
        state = state.copyWith(error: error);
        return;
      }

      // Update entries with actual wins
      final updatedEntries = currentRound.entries.map((entry) {
        return entry.copyWith(actualWins: actualWins[entry.playerId]);
      }).toList();

      // Update round
      final updatedRound = currentRound.copyWith(
        status: RoundStatus.completed,
        entries: updatedEntries,
      );

      // Update rounds list
      final updatedRounds = List<GameRound>.from(game.rounds);
      updatedRounds[game.currentRoundIndex] = updatedRound;

      // Determine next state
      final nextRoundIndex = game.currentRoundIndex + 1;
      final isFinished = nextRoundIndex >= game.rounds.length;

      final updatedGame = game.copyWith(
        rounds: updatedRounds,
        currentRoundIndex: isFinished ? game.currentRoundIndex : nextRoundIndex,
        state: isFinished ? model.GameState.finished : model.GameState.prediction,
      );

      await _repository.saveLastGame(updatedGame);
      state = GameState(currentGame: updatedGame);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> undoLastCompletedRound() async {
    final game = state.currentGame;
    if (game == null) return;

    try {
      // Find the last completed round
      int lastCompletedIndex = -1;
      for (int i = game.rounds.length - 1; i >= 0; i--) {
        if (game.rounds[i].status == RoundStatus.completed) {
          lastCompletedIndex = i;
          break;
        }
      }

      if (lastCompletedIndex == -1) {
        state = state.copyWith(error: 'No completed rounds to undo');
        return;
      }

      // Clear the round
      final roundToClear = game.rounds[lastCompletedIndex];
      final clearedRound = GameRound(
        index: roundToClear.index,
        cards: roundToClear.cards,
        status: RoundStatus.empty,
        entries: roundToClear.entries
            .map((e) => RoundEntry(playerId: e.playerId))
            .toList(),
      );

      // Update rounds list
      final updatedRounds = List<GameRound>.from(game.rounds);
      updatedRounds[lastCompletedIndex] = clearedRound;

      // Update game
      final updatedGame = game.copyWith(
        rounds: updatedRounds,
        currentRoundIndex: lastCompletedIndex,
        state: model.GameState.prediction,
      );

      await _repository.saveLastGame(updatedGame);
      state = GameState(currentGame: updatedGame);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearGame() async {
    await _repository.clearLastGame();
    state = const GameState();
  }

  // Restore state from undo/redo
  void restoreState(model.Game restoredGame) {
    state = GameState(currentGame: restoredGame);
    _repository.saveLastGame(restoredGame);
  }
}
