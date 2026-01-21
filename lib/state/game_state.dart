// lib/state/game_state.dart
import '../domain/models/game.dart';
import '../domain/models/player.dart';
import '../domain/models/round.dart';
import '../domain/logic/scoring.dart';

class GameState {
  final Game? currentGame;
  final bool isLoading;
  final String? error;

  const GameState({
    this.currentGame,
    this.isLoading = false,
    this.error,
  });

  GameState copyWith({
    Game? currentGame,
    bool? isLoading,
    String? error,
  }) =>
      GameState(
        currentGame: currentGame ?? this.currentGame,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  // Derived getters
  Map<String, int> get playerTotals {
    if (currentGame == null) return {};

    final totals = <String, int>{};
    for (final player in currentGame!.players) {
      totals[player.id] = 0;
    }

    for (final round in currentGame!.rounds) {
      if (round.status == RoundStatus.completed) {
        for (final entry in round.entries) {
          if (entry.actualWins != null && entry.predictedWins != null) {
            final points = computeRoundPoints(
              predictedWins: entry.predictedWins!,
              actualWins: entry.actualWins!,
              bonusExact: currentGame!.settings.bonusExact,
            );
            totals[entry.playerId] = (totals[entry.playerId] ?? 0) + points;
          }
        }
      }
    }

    return totals;
  }

  List<LeaderboardEntry> get leaderboard {
    if (currentGame == null) return [];

    final totals = playerTotals;
    final entries = currentGame!.players.map((player) {
      return LeaderboardEntry(
        player: player,
        totalPoints: totals[player.id] ?? 0,
      );
    }).toList();

    entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return entries;
  }

  int? get cardsThisRound {
    if (currentGame == null) return null;
    if (currentGame!.currentRoundIndex >= currentGame!.rounds.length) {
      return null;
    }
    return currentGame!.rounds[currentGame!.currentRoundIndex].cards;
  }

  GameRound? get currentRound {
    if (currentGame == null) return null;
    if (currentGame!.currentRoundIndex >= currentGame!.rounds.length) {
      return null;
    }
    return currentGame!.rounds[currentGame!.currentRoundIndex];
  }
}

class LeaderboardEntry {
  final Player player;
  final int totalPoints;

  const LeaderboardEntry({
    required this.player,
    required this.totalPoints,
  });
}
