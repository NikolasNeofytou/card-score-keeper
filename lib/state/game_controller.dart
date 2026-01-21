// lib/state/game_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/game_repository.dart';
import '../domain/models/game.dart' as model;
import '../domain/models/player.dart';
import '../domain/models/round.dart';
import '../domain/logic/schedule.dart';
import '../domain/logic/rules_engine.dart';
import '../domain/logic/game_rules.dart';
import 'game_state.dart';
import 'game_list_controller.dart';

class GameController extends StateNotifier<GameState> {
  final GameRepository _repository;
  final GameListController _gameListController;
  final _uuid = const Uuid();
  final RulesEngine _rulesEngine;

  GameController(this._repository, this._gameListController)
      : _rulesEngine = CardGameRulesEngine.create(),
        super(const GameState()) {
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

  /// Load a specific game by ID and make it the current game
  Future<void> loadGame(String gameId) async {
    state = state.copyWith(isLoading: true);
    try {
      final game = await _repository.loadGame(gameId);
      if (game != null) {
        await _repository.saveLastGame(game);
        await _gameListController.switchToGame(gameId);
        state = GameState(currentGame: game, isLoading: false);
      } else {
        state = GameState(isLoading: false, error: 'Game not found');
      }
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
          entries: players.map((p) => RoundEntry(playerId: p.id)).toList(),
        );
      }).toList();

      // Create game with timestamps
      final now = DateTime.now();
      final game = model.Game(
        id: _uuid.v4(),
        name: gameName,
        settings:
            model.GameSettings(peakCards: peakCards, bonusExact: bonusExact),
        players: players,
        rounds: rounds,
        currentRoundIndex: 0,
        state: model.GameState.prediction,
        createdAt: now,
        lastModified: now,
      );

      // Save game using repository.saveGame() and update current game reference
      await _repository.saveGame(game);
      await _repository.saveLastGame(game);

      // Update current game ID in game list controller
      await _gameListController.switchToGame(game.id);

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

      // Update game with lastModified timestamp
      final updatedGame = game.copyWith(
        rounds: updatedRounds,
        state: model.GameState.scoring,
      );

      // Save game using repository.saveGame() and update current game reference
      await _repository.saveGame(updatedGame);
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
    final context = RuleContext(
      cardsThisRound: currentRound.cards,
      playerCount: game.players.length,
      roundNumber: game.currentRoundIndex + 1,
      peakCards: game.settings.peakCards,
      bonusExact: game.settings.bonusExact,
    );

    final result = _rulesEngine.validate(context, actualWins);
    return result.firstError;
  }

  /// Get full validation result including warnings
  ValidationResult? validateResultsDetailed(Map<String, int> actualWins) {
    final game = state.currentGame;
    if (game == null) return null;

    final currentRound = game.rounds[game.currentRoundIndex];
    final context = RuleContext(
      cardsThisRound: currentRound.cards,
      playerCount: game.players.length,
      roundNumber: game.currentRoundIndex + 1,
      peakCards: game.settings.peakCards,
      bonusExact: game.settings.bonusExact,
    );

    return _rulesEngine.validate(context, actualWins);
  }

  Future<void> saveResults(Map<String, int> actualWins) async {
    final game = state.currentGame;
    if (game == null) return;

    try {
      final currentRound = game.rounds[game.currentRoundIndex];

      // Validate using rules engine
      final context = RuleContext(
        cardsThisRound: currentRound.cards,
        playerCount: game.players.length,
        roundNumber: game.currentRoundIndex + 1,
        peakCards: game.settings.peakCards,
        bonusExact: game.settings.bonusExact,
      );

      final validationResult = _rulesEngine.validate(context, actualWins);
      if (!validationResult.isValid) {
        state = state.copyWith(error: validationResult.firstError);
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

      // Create updated game with new state and lastModified timestamp
      final updatedGame = game.copyWith(
        rounds: updatedRounds,
        currentRoundIndex: isFinished ? game.currentRoundIndex : nextRoundIndex,
        state:
            isFinished ? model.GameState.finished : model.GameState.prediction,
      );

      // Save game using repository.saveGame() and update current game reference
      await _repository.saveGame(updatedGame);
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

      // Update game with lastModified timestamp
      final updatedGame = game.copyWith(
        rounds: updatedRounds,
        currentRoundIndex: lastCompletedIndex,
        state: model.GameState.prediction,
      );

      // Save game using repository.saveGame() and update current game reference
      await _repository.saveGame(updatedGame);
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
    // Create updated game with new lastModified timestamp
    final updatedGame = restoredGame.copyWith();

    state = GameState(currentGame: updatedGame);
    _repository.saveGame(updatedGame);
    _repository.saveLastGame(updatedGame);
  }
}
