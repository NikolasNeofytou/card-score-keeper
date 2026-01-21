// lib/domain/logic/validation.dart
// DEPRECATED: This file is deprecated. Use validation_service.dart with the rules engine instead.
// This is kept for backward compatibility but will be removed in a future version.

@Deprecated('Use ValidationService.validateResults instead')
String? validateResults({
  required int cardsThisRound,
  required Map<String, int> actualWinsByPlayerId,
}) {
  final sum = actualWinsByPlayerId.values.fold<int>(0, (a, b) => a + b);
  if (sum != cardsThisRound) {
    return 'Total wins must equal $cardsThisRound. Currently: $sum.';
  }
  return null;
}
