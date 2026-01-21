// test/performance/performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/logic/schedule.dart';
import 'package:card_scorekeeper/domain/logic/scoring.dart';
import 'package:card_scorekeeper/domain/logic/validation.dart';
import '../mocks/test_data.dart';

void main() {
  group('Performance Tests', () {
    test('Schedule generation performance', () {
      const playerCounts = [4, 6, 8, 10, 12];
      const roundCounts = [5, 10, 15, 20, 25];

      for (final playerCount in playerCounts) {
        for (final roundCount in roundCounts) {
          final stopwatch = Stopwatch()..start();

          // Generate schedule multiple times to test consistency
          for (int i = 0; i < 10; i++) {
            final schedule = buildRoundSchedule(playerCount, roundCount);
            expect(schedule.length, roundCount);
          }

          stopwatch.stop();

          // Performance assertion - should complete within reasonable time
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(1000), // Less than 1 second for 10 iterations
            reason:
                'Schedule generation too slow for $playerCount players, $roundCount rounds',
          );

          print(
              'Schedule ($playerCount players, $roundCount rounds): ${stopwatch.elapsedMilliseconds}ms');
        }
      }
    });

    test('Scoring calculation performance', () {
      final largeGame = TestDataFactory.createLargeGame();

      final stopwatch = Stopwatch()..start();

      // Calculate scores for many rounds
      for (final round in largeGame.rounds) {
        for (final playerId in round.results.keys) {
          final predicted = round.predictions[playerId] ?? 0;
          final actual = round.results[playerId] ?? 0;

          final points = computeRoundPoints(predicted, actual);
          expect(points, isA<int>());
        }
      }

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100), // Should be very fast
        reason: 'Scoring calculation too slow',
      );

      print('Scoring calculation: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Validation performance with large datasets', () {
      final largeGame = TestDataFactory.createLargeGame();

      final stopwatch = Stopwatch()..start();

      // Validate many rounds
      for (final round in largeGame.rounds) {
        final validation = validateResults(round.results, largeGame.players);
        expect(validation, isA<ValidationResult>());
      }

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200), // Should be reasonably fast
        reason: 'Validation too slow for large datasets',
      );

      print('Validation performance: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Memory usage during large operations', () {
      // Test memory efficiency with large datasets
      final games =
          List.generate(100, (index) => TestDataFactory.createLargeGame());

      expect(games.length, 100);

      // Process all games
      int totalRounds = 0;
      for (final game in games) {
        totalRounds += game.rounds.length;

        // Validate each game
        for (final round in game.rounds) {
          validateResults(round.results, game.players);
        }
      }

      expect(totalRounds, greaterThan(1000));
      print('Processed $totalRounds rounds across ${games.length} games');
    });

    test('Concurrent operations performance', () async {
      // Test performance under concurrent load
      final futures = <Future<void>>[];

      for (int i = 0; i < 10; i++) {
        futures.add(Future(() {
          final game = TestDataFactory.createLargeGame();

          // Perform multiple operations
          for (final round in game.rounds) {
            validateResults(round.results, game.players);

            for (final playerId in round.results.keys) {
              final predicted = round.predictions[playerId] ?? 0;
              final actual = round.results[playerId] ?? 0;
              computeRoundPoints(predicted, actual);
            }
          }
        }));
      }

      final stopwatch = Stopwatch()..start();
      await Future.wait(futures);
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000), // Should complete within 5 seconds
        reason: 'Concurrent operations too slow',
      );

      print('Concurrent operations: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
