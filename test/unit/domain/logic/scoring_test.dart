// test/unit/domain/logic/scoring_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/scoring.dart';
import 'package:card_scorekeeper/domain/models/round.dart';

void main() {
  group('Scoring Logic', () {
    group('calculatePoints', () {
      test('perfect prediction gives correct bonus', () {
        const settings = ScoringSettings(bonusExact: 10);

        expect(calculatePoints(predicted: 3, actual: 3, settings: settings),
            equals(3 + 10)); // Base points + bonus
        expect(calculatePoints(predicted: 0, actual: 0, settings: settings),
            equals(0 + 10)); // Zero tricks + bonus
        expect(calculatePoints(predicted: 5, actual: 5, settings: settings),
            equals(5 + 10)); // High prediction + bonus
      });

      test('incorrect prediction gives zero points', () {
        const settings = ScoringSettings(bonusExact: 10);

        expect(calculatePoints(predicted: 3, actual: 2, settings: settings),
            equals(0));
        expect(calculatePoints(predicted: 3, actual: 4, settings: settings),
            equals(0));
        expect(calculatePoints(predicted: 0, actual: 1, settings: settings),
            equals(0));
        expect(calculatePoints(predicted: 5, actual: 3, settings: settings),
            equals(0));
      });

      test('handles edge cases correctly', () {
        const settings = ScoringSettings(bonusExact: 15);

        // Zero prediction, zero actual
        expect(calculatePoints(predicted: 0, actual: 0, settings: settings),
            equals(15));

        // Maximum possible prediction
        expect(calculatePoints(predicted: 13, actual: 13, settings: settings),
            equals(28));

        // Different bonus values
        const highBonus = ScoringSettings(bonusExact: 20);
        expect(calculatePoints(predicted: 2, actual: 2, settings: highBonus),
            equals(22));
      });

      test('validates input parameters', () {
        const settings = ScoringSettings(bonusExact: 10);

        expect(
            () => calculatePoints(predicted: -1, actual: 0, settings: settings),
            throwsArgumentError);
        expect(
            () => calculatePoints(predicted: 0, actual: -1, settings: settings),
            throwsArgumentError);
        expect(
            () => calculatePoints(predicted: 14, actual: 0, settings: settings),
            throwsArgumentError);
        expect(
            () => calculatePoints(predicted: 0, actual: 14, settings: settings),
            throwsArgumentError);
      });
    });

    group('Round Scoring', () {
      test('calculates correct scores for complete round', () {
        final round = GameRound(
          index: 0,
          cards: 5,
          status: RoundStatus.completed,
          entries: [
            const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 2),
            const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 3),
            const RoundEntry(playerId: 'p3', predictedWins: 2, actualWins: 0),
          ],
        );

        const settings = ScoringSettings(bonusExact: 10);
        final scores = calculateRoundScores(round, settings);

        expect(scores['p1'], equals(12)); // 2 + 10 bonus
        expect(scores['p2'], equals(0)); // Wrong prediction
        expect(scores['p3'], equals(0)); // Wrong prediction
      });

      test('validates round completion', () {
        final incompleteRound = GameRound(
          index: 0,
          cards: 5,
          status: RoundStatus.predictionsSet,
          entries: [
            const RoundEntry(
                playerId: 'p1', predictedWins: 2, actualWins: null),
          ],
        );

        const settings = ScoringSettings(bonusExact: 10);
        expect(() => calculateRoundScores(incompleteRound, settings),
            throwsStateError);
      });

      test('handles zero-sum validation', () {
        final round = GameRound(
          index: 0,
          cards: 5,
          status: RoundStatus.completed,
          entries: [
            const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 2),
            const RoundEntry(playerId: 'p2', predictedWins: 2, actualWins: 2),
            const RoundEntry(
                playerId: 'p3',
                predictedWins: 1,
                actualWins: 2), // Total = 6, should be 5
          ],
        );

        const settings = ScoringSettings(bonusExact: 10);
        expect(
            () => calculateRoundScores(round, settings), throwsArgumentError);
      });
    });

    group('Cumulative Scoring', () {
      test('calculates cumulative scores correctly', () {
        final rounds = [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 1, actualWins: 1),
              const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 2),
              const RoundEntry(playerId: 'p3', predictedWins: 1, actualWins: 0),
            ],
          ),
          GameRound(
            index: 1,
            cards: 4,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 1),
              const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 1),
              const RoundEntry(playerId: 'p3', predictedWins: 1, actualWins: 2),
            ],
          ),
        ];

        const settings = ScoringSettings(bonusExact: 10);
        final cumulative = calculateCumulativeScores(rounds, settings);

        // Round 1: p1=11 (1+10), p2=0, p3=0
        // Round 2: p1=0, p2=11 (1+10), p3=0
        // Cumulative: p1=11, p2=11, p3=0
        expect(cumulative['p1'], equals(11));
        expect(cumulative['p2'], equals(11));
        expect(cumulative['p3'], equals(0));
      });

      test('handles empty rounds list', () {
        const settings = ScoringSettings(bonusExact: 10);
        final scores = calculateCumulativeScores([], settings);
        expect(scores, isEmpty);
      });

      test('handles missing players consistently', () {
        final rounds = [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 1, actualWins: 1),
              const RoundEntry(playerId: 'p2', predictedWins: 2, actualWins: 2),
            ],
          ),
          GameRound(
            index: 1,
            cards: 4,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 2),
              const RoundEntry(
                  playerId: 'p3',
                  predictedWins: 2,
                  actualWins: 2), // New player
            ],
          ),
        ];

        const settings = ScoringSettings(bonusExact: 10);
        final cumulative = calculateCumulativeScores(rounds, settings);

        expect(cumulative['p1'], equals(24)); // 11 + 12 + 10
        expect(cumulative['p2'], equals(12)); // 12 + 0 (missing in round 2)
        expect(cumulative['p3'], equals(12)); // 0 (missing in round 1) + 12
      });
    });

    group('Leaderboard Generation', () {
      test('sorts players by score descending', () {
        final scores = {
          'Alice': 25,
          'Bob': 30,
          'Charlie': 20,
          'David': 30,
        };

        final leaderboard = generateLeaderboard(scores);

        expect(leaderboard.length, equals(4));
        expect(leaderboard[0].playerName, equals('Bob'));
        expect(leaderboard[0].totalPoints, equals(30));
        expect(leaderboard[1].playerName, equals('David'));
        expect(leaderboard[1].totalPoints, equals(30));
        expect(leaderboard[2].playerName, equals('Alice'));
        expect(leaderboard[2].totalPoints, equals(25));
        expect(leaderboard[3].playerName, equals('Charlie'));
        expect(leaderboard[3].totalPoints, equals(20));
      });

      test('handles tied scores with stable sort', () {
        final scores = {
          'First': 20,
          'Second': 20,
          'Third': 15,
        };

        final leaderboard = generateLeaderboard(scores);

        expect(leaderboard[0].totalPoints, equals(20));
        expect(leaderboard[1].totalPoints, equals(20));
        expect(leaderboard[2].totalPoints, equals(15));

        // Names should maintain input order for ties
        expect(['First', 'Second'].contains(leaderboard[0].playerName), isTrue);
        expect(['First', 'Second'].contains(leaderboard[1].playerName), isTrue);
      });

      test('handles empty scores', () {
        final leaderboard = generateLeaderboard({});
        expect(leaderboard, isEmpty);
      });

      test('handles negative scores', () {
        final scores = {
          'Positive': 10,
          'Zero': 0,
          'Negative': -5,
        };

        final leaderboard = generateLeaderboard(scores);

        expect(leaderboard[0].playerName, equals('Positive'));
        expect(leaderboard[0].totalPoints, equals(10));
        expect(leaderboard[1].playerName, equals('Zero'));
        expect(leaderboard[1].totalPoints, equals(0));
        expect(leaderboard[2].playerName, equals('Negative'));
        expect(leaderboard[2].totalPoints, equals(-5));
      });
    });
  });
}
