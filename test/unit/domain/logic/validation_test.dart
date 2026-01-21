// test/unit/domain/logic/validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/validation.dart';

void main() {
  group('Validation Logic', () {
    group('Result Validation', () {
      test('accepts valid results where sum equals cards', () {
        final result = validateResults(
          cardsThisRound: 5,
          actualWinsByPlayerId: {
            'p1': 2,
            'p2': 2,
            'p3': 1,
          },
        );

        expect(result, isNull); // No error
      });

      test('rejects results where sum does not equal cards', () {
        final result = validateResults(
          cardsThisRound: 5,
          actualWinsByPlayerId: {
            'p1': 2,
            'p2': 3,
            'p3': 1,
          }, // Sum = 6, should be 5
        );

        expect(result, isNotNull);
        expect(result, contains('Total wins must equal 5'));
        expect(result, contains('Currently: 6'));
      });

      test('handles edge case with zero cards', () {
        final result = validateResults(
          cardsThisRound: 0,
          actualWinsByPlayerId: {
            'p1': 0,
            'p2': 0,
            'p3': 0,
          },
        );

        expect(result, isNull); // Valid
      });

      test('handles single player', () {
        final result = validateResults(
          cardsThisRound: 3,
          actualWinsByPlayerId: {
            'p1': 3,
          },
        );

        expect(result, isNull); // Valid
      });

      test('rejects when sum is less than cards', () {
        final result = validateResults(
          cardsThisRound: 5,
          actualWinsByPlayerId: {
            'p1': 1,
            'p2': 1,
            'p3': 1,
          }, // Sum = 3, should be 5
        );

        expect(result, isNotNull);
        expect(result, contains('Total wins must equal 5'));
        expect(result, contains('Currently: 3'));
      });

      test('handles empty player map', () {
        final result = validateResults(
          cardsThisRound: 0,
          actualWinsByPlayerId: {},
        );

        expect(result, isNull); // Valid for 0 cards
      });

      test('rejects empty players with non-zero cards', () {
        final result = validateResults(
          cardsThisRound: 5,
          actualWinsByPlayerId: {},
        );

        expect(result, isNotNull);
        expect(result, contains('Total wins must equal 5'));
        expect(result, contains('Currently: 0'));
      });

      test('provides clear error messages', () {
        final result = validateResults(
          cardsThisRound: 7,
          actualWinsByPlayerId: {
            'Alice': 3,
            'Bob': 2,
            'Charlie': 1,
          }, // Sum = 6, should be 7
        );

        expect(result, contains('7'));
        expect(result, contains('6'));
        expect(result, contains('Total wins'));
      });
    });

    group('Validation Edge Cases', () {
      test('handles maximum reasonable values', () {
        final result = validateResults(
          cardsThisRound: 52,
          actualWinsByPlayerId: {
            'p1': 26,
            'p2': 26,
          },
        );

        expect(result, isNull);
      });

      test('handles negative wins (edge case)', () {
        // While this shouldn't happen in normal gameplay,
        // the validation function should handle it gracefully
        final result = validateResults(
          cardsThisRound: 5,
          actualWinsByPlayerId: {
            'p1': -1,
            'p2': 3,
            'p3': 3,
          }, // Sum = 5
        );

        expect(result, isNull); // Sum is correct, even with negative
      });

      test('function is marked as deprecated', () {
        // This test just verifies the function still works
        // even though it's deprecated
        final result = validateResults(
          cardsThisRound: 3,
          actualWinsByPlayerId: {'p1': 1, 'p2': 1, 'p3': 1},
        );

        expect(result, isNull);
      });
    });
  });
}
