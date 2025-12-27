// lib/domain/logic/scoring.dart
int computeRoundPoints({
  required int predictedWins,
  required int actualWins,
  required int bonusExact,
}) {
  final correct = actualWins == predictedWins;
  return actualWins + (correct ? bonusExact : 0);
}
