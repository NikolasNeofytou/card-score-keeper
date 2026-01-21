// lib/domain/logic/validation_service.dart
import 'rules_engine.dart';
import 'game_rules.dart';

/// Enhanced validation service that uses the rules engine
class ValidationService {
  static final RulesEngine _rulesEngine = CardGameRulesEngine.create();

  /// Validate game results using the rules engine
  static ValidationResult validateGameResults({
    required int cardsThisRound,
    required int playerCount,
    required int roundNumber,
    required int peakCards,
    required int bonusExact,
    required Map<String, int> actualWinsByPlayerId,
    Map<String, dynamic> additionalData = const {},
  }) {
    final context = RuleContext(
      cardsThisRound: cardsThisRound,
      playerCount: playerCount,
      roundNumber: roundNumber,
      peakCards: peakCards,
      bonusExact: bonusExact,
      additionalData: additionalData,
    );

    return _rulesEngine.validate(context, actualWinsByPlayerId);
  }

  /// Simple validation that returns just the first error (backward compatibility)
  static String? validateResults({
    required int cardsThisRound,
    required Map<String, int> actualWinsByPlayerId,
    int? playerCount,
    int? roundNumber,
    int? peakCards,
    int? bonusExact,
  }) {
    final result = validateGameResults(
      cardsThisRound: cardsThisRound,
      playerCount: playerCount ?? actualWinsByPlayerId.length,
      roundNumber: roundNumber ?? 1,
      peakCards: peakCards ?? 10,
      bonusExact: bonusExact ?? 10,
      actualWinsByPlayerId: actualWinsByPlayerId,
    );

    return result.firstError;
  }

  /// Get all available rules
  static List<GameRule> get availableRules => _rulesEngine.rules;

  /// Get rules engine for advanced usage
  static RulesEngine get rulesEngine => _rulesEngine;
}
