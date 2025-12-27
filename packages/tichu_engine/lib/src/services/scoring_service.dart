import '../models/game_state.dart';
import '../models/player_state.dart';
import '../config/ruleset.dart';

/// Service for calculating Tichu scores
class ScoringService {
  final TichuRuleset ruleset;

  const ScoringService(this.ruleset);

  /// Calculate round score for a team
  Map<String, int> calculateRoundScores(TichuGameState state) {
    final scores = <String, int>{'team0': 0, 'team1': 0};

    // Check for double victory (1-2 finish)
    if (ruleset.allowDoubleVictory && _hasDoubleVictory(state)) {
      final winningTeam = state.teamForPlayer(
        state.players
            .firstWhere((p) => p.finishPosition == 1)
            .id as int,
      );
      final teamKey = 'team$winningTeam';
      scores[teamKey] = ruleset.doubleVictoryPoints;
      return scores;
    }

    // Calculate card points for each team
    for (int i = 0; i < 4; i++) {
      final player = state.players[i];
      final team = 'team${state.teamForPlayer(i)}';
      scores[team] = (scores[team] ?? 0) + player.pointsWon;

      // Add points from unfinished player's hand to the team that finished first
      if (!player.hasFinished) {
        final firstFinishTeam = state.teamForPlayer(
          state.players
              .firstWhere((p) => p.finishPosition == 1)
              .id as int,
        );
        scores['team$firstFinishTeam'] =
            (scores['team$firstFinishTeam'] ?? 0) + player.pointsInHand;
      }
    }

    // Apply Tichu/Grand Tichu bonuses/penalties
    for (int i = 0; i < 4; i++) {
      final player = state.players[i];
      final team = 'team${state.teamForPlayer(i)}';

      if (player.hasCalledGrandTichu) {
        if (player.finishPosition == 1) {
          scores[team] = (scores[team] ?? 0) + ruleset.grandTichuPoints;
        } else {
          scores[team] = (scores[team] ?? 0) - ruleset.grandTichuPoints;
        }
      } else if (player.hasCalledTichu) {
        if (player.finishPosition == 1) {
          scores[team] = (scores[team] ?? 0) + ruleset.tichuPoints;
        } else {
          scores[team] = (scores[team] ?? 0) - ruleset.tichuPoints;
        }
      }
    }

    return scores;
  }

  /// Check if a team achieved double victory (1-2 finish)
  bool _hasDoubleVictory(TichuGameState state) {
    final finishers = state.players.where((p) => p.hasFinished).toList();
    if (finishers.length < 2) return false;

    final first = finishers.firstWhere((p) => p.finishPosition == 1);
    final second = finishers.firstWhere((p) => p.finishPosition == 2);

    final firstTeam = state.teamForPlayer(
      state.players.indexOf(first),
    );
    final secondTeam = state.teamForPlayer(
      state.players.indexOf(second),
    );

    return firstTeam == secondTeam;
  }

  /// Check if game is over (target score reached)
  bool isGameOver(Map<String, int> teamScores) {
    return teamScores.values.any((score) => score >= ruleset.targetScore);
  }

  /// Get winning team
  String? getWinningTeam(Map<String, int> teamScores) {
    if (!isGameOver(teamScores)) return null;

    return teamScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
