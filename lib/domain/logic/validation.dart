// lib/domain/logic/validation.dart
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
