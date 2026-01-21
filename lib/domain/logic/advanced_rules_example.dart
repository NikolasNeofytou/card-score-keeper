// lib/domain/logic/advanced_rules_example.dart
import 'rules_engine.dart';
import 'game_rules.dart'; // Import for the standard rules like TotalWinsRule

/// Example of how to create custom rules for different game variants
/// This demonstrates the extensibility of the rules engine

/// Example rule for tournament mode
class TournamentModeRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'tournament_mode';

  @override
  String get description => 'Special validation rules for tournament play';

  @override
  bool isApplicable(RuleContext context) {
    // Only apply in tournament mode (determined by additional data)
    return context.additionalData['tournament_mode'] == true;
  }

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    // Example: In tournament mode, tied results are not allowed in final rounds
    final isFinalRound = context.additionalData['is_final_round'] == true;
    if (isFinalRound) {
      final winCounts = <int, int>{};
      for (final wins in actualWins.values) {
        winCounts[wins] = (winCounts[wins] ?? 0) + 1;
      }

      if (winCounts.values.any((count) => count > 1)) {
        return RuleResult.invalid(
          'Tied results are not allowed in tournament final rounds',
        );
      }
    }

    return RuleResult.valid();
  }
}

/// Example rule for custom scoring variants
class CustomScoringRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'custom_scoring';

  @override
  String get description => 'Validates results for custom scoring variants';

  @override
  bool isApplicable(RuleContext context) {
    return context.additionalData['scoring_variant'] != null;
  }

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    final variant = context.additionalData['scoring_variant'] as String?;

    switch (variant) {
      case 'no_zero_allowed':
        if (actualWins.values.any((wins) => wins == 0)) {
          return RuleResult.invalid('Zero wins not allowed in this variant');
        }
        break;
      case 'must_have_winner':
        final maxWins = actualWins.values.reduce((a, b) => a > b ? a : b);
        final winnersCount =
            actualWins.values.where((w) => w == maxWins).length;
        if (winnersCount > 1) {
          return RuleResult.invalid(
              'Must have a single winner (no ties allowed)');
        }
        break;
    }

    return RuleResult.valid();
  }
}

/// Example rule that considers game history
class GameHistoryRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'game_history';

  @override
  String get description => 'Validates based on previous round patterns';

  @override
  bool isApplicable(RuleContext context) {
    return context.additionalData['previous_rounds'] != null;
  }

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    // Example: Warn if a player has won 0 tricks for 3 consecutive rounds
    final previousRounds = context.additionalData['previous_rounds'] as List?;
    if (previousRounds != null && previousRounds.length >= 2) {
      final warnings = <String>[];

      for (final playerId in actualWins.keys) {
        if (actualWins[playerId] == 0) {
          // Check if this player had 0 wins in previous rounds
          int consecutiveZeros = 1;
          for (int i = previousRounds.length - 1; i >= 0; i--) {
            final round = previousRounds[i] as Map<String, dynamic>?;
            if (round?[playerId] == 0) {
              consecutiveZeros++;
            } else {
              break;
            }
          }

          if (consecutiveZeros >= 3) {
            warnings.add(
                'Player $playerId has had 0 wins for $consecutiveZeros consecutive rounds');
          }
        }
      }

      if (warnings.isNotEmpty) {
        return RuleResult.valid(
          warning: warnings.join('; '),
          metadata: {'patterns_detected': warnings},
        );
      }
    }

    return RuleResult.valid();
  }
}

/// Factory for creating specialized rules engines
class AdvancedRulesEngineFactory {
  static RulesEngine createTournamentEngine() {
    final engine = RulesEngine();

    // Add all standard rules
    engine.addRule(TotalWinsRule());
    engine.addRule(NonNegativeWinsRule());

    // Add tournament-specific rules
    engine.addRule(TournamentModeRule());

    return engine;
  }

  static RulesEngine createCustomScoringEngine(String variant) {
    final engine = RulesEngine();

    // Add standard rules
    engine.addRule(TotalWinsRule());
    engine.addRule(NonNegativeWinsRule());

    // Add custom scoring rule
    engine.addRule(CustomScoringRule());

    return engine;
  }

  static RulesEngine createHistoryAwareEngine() {
    final engine = RulesEngine();

    // Add all standard rules
    engine.addRule(TotalWinsRule());
    engine.addRule(NonNegativeWinsRule());

    // Add history-based rules
    engine.addRule(GameHistoryRule());

    return engine;
  }
}

// IMPORTANT: These are examples for reference.
// The actual implementation can be found in game_rules.dart and is used in the GameController.
// These advanced rules would require additional data to be passed through the RuleContext.
