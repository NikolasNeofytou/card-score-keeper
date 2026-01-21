// lib/domain/logic/game_rules.dart
import 'rules_engine.dart';

/// Rule that validates the total wins matches the number of cards in the round
class TotalWinsRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'total_wins_validation';

  @override
  String get description =>
      'Total wins must equal the number of cards dealt this round';

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    final sum = actualWins.values.fold<int>(0, (a, b) => a + b);

    if (sum != context.cardsThisRound) {
      return RuleResult.invalid(
        'Total wins must equal ${context.cardsThisRound}. Currently: $sum.',
        metadata: {
          'expected': context.cardsThisRound,
          'actual': sum,
          'difference': sum - context.cardsThisRound,
        },
      );
    }

    return RuleResult.valid();
  }
}

/// Rule that validates all players have entered results
class AllPlayersHaveResultsRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'all_players_results';

  @override
  String get description => 'All players must have results entered';

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    if (actualWins.length != context.playerCount) {
      return RuleResult.invalid(
        'Results missing for ${context.playerCount - actualWins.length} player(s)',
        metadata: {
          'expected_players': context.playerCount,
          'actual_players': actualWins.length,
        },
      );
    }

    return RuleResult.valid();
  }
}

/// Rule that validates wins are non-negative
class NonNegativeWinsRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'non_negative_wins';

  @override
  String get description => 'Player wins must be non-negative';

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    final negativeWins =
        actualWins.entries.where((entry) => entry.value < 0).toList();

    if (negativeWins.isNotEmpty) {
      final playerIds = negativeWins.map((e) => e.key).join(', ');
      return RuleResult.invalid(
        'Players cannot have negative wins: $playerIds',
        metadata: {
          'negative_players': negativeWins.map((e) => e.key).toList(),
        },
      );
    }

    return RuleResult.valid();
  }
}

/// Rule that validates wins don't exceed the cards dealt
class MaxWinsRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'max_wins_per_player';

  @override
  String get description =>
      'Player wins cannot exceed the number of cards dealt';

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    final excessiveWins = actualWins.entries
        .where((entry) => entry.value > context.cardsThisRound)
        .toList();

    if (excessiveWins.isNotEmpty) {
      final violations =
          excessiveWins.map((e) => '${e.key}: ${e.value}').join(', ');
      return RuleResult.invalid(
        'Players cannot win more than ${context.cardsThisRound} tricks: $violations',
        metadata: {
          'excessive_players': excessiveWins.map((e) => e.key).toList(),
          'max_allowed': context.cardsThisRound,
        },
      );
    }

    return RuleResult.valid();
  }
}

/// Rule that provides warnings for unusual but valid scenarios
class UnusualResultsWarningRule extends GameRule<Map<String, int>> {
  @override
  String get name => 'unusual_results_warning';

  @override
  String get description => 'Warns about unusual but valid game results';

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult validate(RuleContext context, Map<String, int> actualWins) {
    final warnings = <String>[];

    // Check if one player won all tricks
    final maxWins = actualWins.values.reduce((a, b) => a > b ? a : b);
    if (maxWins == context.cardsThisRound && context.cardsThisRound > 1) {
      warnings.add('One player won all ${context.cardsThisRound} tricks');
    }

    // Check if no one won any tricks (only possible with 0 cards)
    final totalWins = actualWins.values.fold<int>(0, (a, b) => a + b);
    if (totalWins == 0 && context.cardsThisRound > 0) {
      warnings.add('No tricks won with ${context.cardsThisRound} cards dealt');
    }

    if (warnings.isNotEmpty) {
      return RuleResult.valid(
        warning: warnings.join('; '),
        metadata: {'unusual_patterns': warnings},
      );
    }

    return RuleResult.valid();
  }
}

/// Factory class to create a configured rules engine for the card game
class CardGameRulesEngine {
  static RulesEngine create() {
    final engine = RulesEngine();

    // Add rules in order of priority
    engine.addRule(AllPlayersHaveResultsRule());
    engine.addRule(NonNegativeWinsRule());
    engine.addRule(MaxWinsRule());
    engine.addRule(TotalWinsRule());
    engine.addRule(UnusualResultsWarningRule());

    return engine;
  }
}
