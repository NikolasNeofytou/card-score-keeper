// test/unit/domain/logic/validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/validation.dart';
import 'package:card_scorekeeper/domain/models/round.dart';
import 'package:card_scorekeeper/domain/models/player.dart';

void main() {
  group('Validation Logic', () {
    group('Player Name Validation', () {
      test('accepts valid player names', () {
        expect(validatePlayerName('Alice'), isNull);
        expect(validatePlayerName('Bob123'), isNull);
        expect(validatePlayerName('Player-One'), isNull);
        expect(validatePlayerName('Player_Two'), isNull);
        expect(validatePlayerName('A'), isNull); // Single character
        expect(validatePlayerName('VeryLongPlayerNameThatShouldStillBeValid'),
            isNull);
      });

      test('rejects invalid player names', () {
        expect(validatePlayerName(''), isNotNull);
        expect(validatePlayerName('   '), isNotNull); // Only whitespace
        expect(validatePlayerName('Player@Name'), isNotNull); // Special chars
        expect(validatePlayerName('Player Name!'), isNotNull); // Exclamation
        expect(validatePlayerName('Player\tName'), isNotNull); // Tab character
        expect(validatePlayerName('Player\nName'), isNotNull); // Newline
      });

      test('handles edge cases', () {
        expect(validatePlayerName(' Alice '), isNull); // Trimmed spaces OK
        expect(validatePlayerName('123'), isNull); // All numbers OK
        expect(validatePlayerName('---'), isNull); // All dashes OK
        expect(validatePlayerName('Player Name'), isNull); // Internal space OK
      });
    });

    group('Prediction Validation', () {
      test('accepts valid predictions', () {
        expect(validatePrediction(0, 5), isNull); // Zero prediction
        expect(validatePrediction(3, 5), isNull); // Normal prediction
        expect(validatePrediction(5, 5), isNull); // Max prediction
      });

      test('rejects invalid predictions', () {
        expect(validatePrediction(-1, 5), isNotNull); // Negative
        expect(validatePrediction(6, 5), isNotNull); // Exceeds cards
        expect(validatePrediction(10, 5), isNotNull); // Way too high
      });

      test('handles edge cases', () {
        expect(validatePrediction(0, 0), isNull); // Zero cards, zero prediction
        expect(validatePrediction(13, 13), isNull); // Maximum possible
      });
    });

    group('Actual Tricks Validation', () {
      test('accepts valid actual tricks', () {
        expect(validateActualTricks(0, 5), isNull);
        expect(validateActualTricks(3, 5), isNull);
        expect(validateActualTricks(5, 5), isNull);
      });

      test('rejects invalid actual tricks', () {
        expect(validateActualTricks(-1, 5), isNotNull);
        expect(validateActualTricks(6, 5), isNotNull);
      });
    });

    group('Round Sum Validation', () {
      test('accepts valid round sums', () {
        final entries = [
          const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 2),
          const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 2),
          const RoundEntry(playerId: 'p3', predictedWins: 2, actualWins: 1),
        ];

        expect(validateRoundSum(entries, 5), isNull); // Sum = 5
      });

      test('rejects invalid round sums', () {
        final entries = [
          const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 3),
          const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 2),
          const RoundEntry(playerId: 'p3', predictedWins: 2, actualWins: 1),
        ];

        expect(validateRoundSum(entries, 5), isNotNull); // Sum = 6, should be 5
      });

      test('handles incomplete entries', () {
        final entries = [
          const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 2),
          const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: null),
        ];

        expect(validateRoundSum(entries, 5), isNotNull); // Incomplete
      });

      test('handles empty entries', () {
        expect(validateRoundSum([], 5), isNotNull);
      });
    });

    group('Prediction Sum Validation', () {
      test('enforces prediction sum rules', () {
        const cards = 5;

        // Valid: Sum not equal to cards
        final validEntries = [
          const RoundEntry(playerId: 'p1', predictedWins: 2),
          const RoundEntry(playerId: 'p2', predictedWins: 1),
          const RoundEntry(playerId: 'p3', predictedWins: 1),
        ]; // Sum = 4, cards = 5, valid

        expect(validatePredictionSum(validEntries, cards), isNull);

        // Invalid: Sum equals cards (not allowed in some variants)
        final invalidEntries = [
          const RoundEntry(playerId: 'p1', predictedWins: 2),
          const RoundEntry(playerId: 'p2', predictedWins: 2),
          const RoundEntry(playerId: 'p3', predictedWins: 1),
        ]; // Sum = 5, cards = 5, might be invalid

        expect(validatePredictionSum(invalidEntries, cards, allowEqual: false),
            isNotNull);
        expect(validatePredictionSum(invalidEntries, cards, allowEqual: true),
            isNull);
      });
    });

    group('Game State Validation', () {
      test('validates complete game state', () {
        final players = [
          const Player(id: 'p1', name: 'Alice'),
          const Player(id: 'p2', name: 'Bob'),
          const Player(id: 'p3', name: 'Charlie'),
        ];

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
        ];

        expect(validateGameState(players, rounds), isNull);
      });

      test('detects player consistency issues', () {
        final players = [
          const Player(id: 'p1', name: 'Alice'),
          const Player(id: 'p2', name: 'Bob'),
        ];

        final rounds = [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 1, actualWins: 1),
              const RoundEntry(
                  playerId: 'p3',
                  predictedWins: 2,
                  actualWins: 2), // Unknown player
            ],
          ),
        ];

        expect(validateGameState(players, rounds), isNotNull);
      });

      test('detects missing player entries', () {
        final players = [
          const Player(id: 'p1', name: 'Alice'),
          const Player(id: 'p2', name: 'Bob'),
          const Player(id: 'p3', name: 'Charlie'),
        ];

        final rounds = [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 1, actualWins: 1),
              const RoundEntry(playerId: 'p2', predictedWins: 2, actualWins: 2),
              // Missing p3
            ],
          ),
        ];

        expect(validateGameState(players, rounds), isNotNull);
      });
    });

    group('Edge Cases and Error Conditions', () {
      test('handles null and empty inputs gracefully', () {
        expect(validatePlayerName(null), isNotNull);
        expect(validatePrediction(null, 5), isNotNull);
        expect(validateActualTricks(null, 5), isNotNull);
        expect(validateRoundSum(null, 5), isNotNull);
        expect(validateGameState([], []), isNull); // Empty game is valid
      });

      test('validates extreme values', () {
        expect(validatePrediction(999, 5), isNotNull);
        expect(validateActualTricks(-999, 5), isNotNull);
        expect(validatePrediction(0, 999), isNotNull); // Cards too high
        expect(validateActualTricks(0, -1), isNotNull); // Negative cards
      });

      test('validates complex scenarios', () {
        // Round with all zero predictions and results
        final zeroRound = [
          const RoundEntry(playerId: 'p1', predictedWins: 0, actualWins: 0),
          const RoundEntry(playerId: 'p2', predictedWins: 0, actualWins: 0),
          const RoundEntry(playerId: 'p3', predictedWins: 0, actualWins: 0),
        ];

        expect(validateRoundSum(zeroRound, 0), isNull);

        // Round where everyone predicts max
        final maxRound = [
          const RoundEntry(playerId: 'p1', predictedWins: 5, actualWins: 2),
          const RoundEntry(playerId: 'p2', predictedWins: 5, actualWins: 2),
          const RoundEntry(playerId: 'p3', predictedWins: 5, actualWins: 1),
        ];

        expect(validateRoundSum(maxRound, 5), isNull);
        expect(validatePredictionSum(maxRound, 5), isNotNull); // Sum > cards
      });
    });

    group('Validation Message Quality', () {
      test('provides helpful error messages', () {
        final error = validatePlayerName('');
        expect(error, contains('name'));
        expect(error, contains('empty').or(contains('required')));

        final predictionError = validatePrediction(-1, 5);
        expect(predictionError, contains('prediction'));
        expect(predictionError, contains('negative').or(contains('invalid')));

        final sumError = validateRoundSum([
          const RoundEntry(playerId: 'p1', predictedWins: 1, actualWins: 6),
        ], 5);
        expect(sumError, contains('sum').or(contains('total')));
      });

      test('error messages are user-friendly', () {
        final errors = [
          validatePlayerName('@invalid'),
          validatePrediction(10, 5),
          validateActualTricks(-1, 5),
        ];

        for (final error in errors) {
          expect(error, isNotNull);
          expect(error!.length, greaterThan(10)); // Meaningful message
          expect(error, isNot(contains('Exception')));
          expect(error, isNot(contains('Error')));
        }
      });
    });
  });
}
