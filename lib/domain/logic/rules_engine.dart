// lib/domain/logic/rules_engine.dart

/// Abstract base class for game rules
abstract class GameRule<T> {
  String get name;
  String get description;
  bool isApplicable(RuleContext context);
  RuleResult validate(RuleContext context, T input);
}

/// Context passed to rules containing game state
class RuleContext {
  final int cardsThisRound;
  final int playerCount;
  final int roundNumber;
  final int peakCards;
  final int bonusExact;
  final Map<String, dynamic> additionalData;

  const RuleContext({
    required this.cardsThisRound,
    required this.playerCount,
    required this.roundNumber,
    required this.peakCards,
    required this.bonusExact,
    this.additionalData = const {},
  });
}

/// Result of rule validation
class RuleResult {
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;
  final Map<String, dynamic> metadata;

  const RuleResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
    this.metadata = const {},
  });

  factory RuleResult.valid({String? warning, Map<String, dynamic>? metadata}) =>
      RuleResult(
        isValid: true,
        warningMessage: warning,
        metadata: metadata ?? {},
      );

  factory RuleResult.invalid(String error, {Map<String, dynamic>? metadata}) =>
      RuleResult(
        isValid: false,
        errorMessage: error,
        metadata: metadata ?? {},
      );
}

/// Combined result of multiple rules
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    this.metadata = const {},
  });

  factory ValidationResult.fromResults(List<RuleResult> results) {
    final errors = <String>[];
    final warnings = <String>[];
    final metadata = <String, dynamic>{};

    for (final result in results) {
      if (result.errorMessage != null) {
        errors.add(result.errorMessage!);
      }
      if (result.warningMessage != null) {
        warnings.add(result.warningMessage!);
      }
      metadata.addAll(result.metadata);
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      metadata: metadata,
    );
  }

  String? get firstError => errors.isNotEmpty ? errors.first : null;
  String? get firstWarning => warnings.isNotEmpty ? warnings.first : null;
}

/// Main rules engine that applies multiple rules
class RulesEngine {
  final List<GameRule> _rules = [];

  void addRule(GameRule rule) {
    _rules.add(rule);
  }

  void removeRule(String ruleName) {
    _rules.removeWhere((rule) => rule.name == ruleName);
  }

  List<GameRule> get rules => List.unmodifiable(_rules);

  ValidationResult validate<T>(RuleContext context, T input) {
    final results = <RuleResult>[];

    for (final rule in _rules) {
      if (rule.isApplicable(context)) {
        final result = rule.validate(context, input);
        results.add(result);
      }
    }

    return ValidationResult.fromResults(results);
  }
}
