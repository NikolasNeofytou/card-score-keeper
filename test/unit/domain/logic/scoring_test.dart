// test/unit/domain/logic/scoring_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/scoring.dart';

void main() {
  group('Scoring Logic', () {
    group('Round Points Calculation', () {
      test('calculates correct points for perfect predictions', () {
        expect(
            computeRoundPoints(predictedWins: 3, actualWins: 3, bonusExact: 10),
            equals(13)); // 3 + 10 bonus

        expect(
            computeRoundPoints(predictedWins: 0, actualWins: 0, bonusExact: 10),
            equals(10)); // 0 + 10 bonus

        expect(
            computeRoundPoints(predictedWins: 5, actualWins: 5, bonusExact: 10),
            equals(15)); // 5 + 10 bonus
      });

      test('calculates correct points for incorrect predictions', () {
        expect(
            computeRoundPoints(predictedWins: 3, actualWins: 2, bonusExact: 10),
            equals(2)); // 2 wins, no bonus

        expect(
            computeRoundPoints(predictedWins: 3, actualWins: 4, bonusExact: 10),
            equals(4)); // 4 wins, no bonus

        expect(
            computeRoundPoints(predictedWins: 0, actualWins: 1, bonusExact: 10),
            equals(1)); // 1 win, no bonus
      });

      test('handles different bonus amounts', () {
        expect(
            computeRoundPoints(predictedWins: 2, actualWins: 2, bonusExact: 15),
            equals(17)); // 2 + 15 bonus

        expect(
            computeRoundPoints(predictedWins: 0, actualWins: 0, bonusExact: 5),
            equals(5)); // 0 + 5 bonus

        expect(
            computeRoundPoints(predictedWins: 1, actualWins: 1, bonusExact: 0),
            equals(1)); // 1 + 0 bonus
      });

      test('bonus only applies when prediction is exact', () {
        const bonusExact = 10;

        // Exact matches get bonus
        expect(
            computeRoundPoints(
                predictedWins: 3, actualWins: 3, bonusExact: bonusExact),
            equals(13));

        // Close but not exact - no bonus
        expect(
            computeRoundPoints(
                predictedWins: 3, actualWins: 2, bonusExact: bonusExact),
            equals(2));

        expect(
            computeRoundPoints(
                predictedWins: 3, actualWins: 4, bonusExact: bonusExact),
            equals(4));
      });
    });
  });
}
