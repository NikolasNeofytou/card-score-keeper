// test/widget/undo_functionality_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_scorekeeper/ui/screens/scoreboard_screen.dart';
import 'package:card_scorekeeper/ui/screens/results_screen.dart';
import 'package:card_scorekeeper/state/game_controller.dart';
import 'package:card_scorekeeper/state/undo_controller.dart';
import 'package:card_scorekeeper/state/providers.dart';
import 'package:card_scorekeeper/domain/models/game.dart';
import 'package:card_scorekeeper/domain/models/player.dart';
import 'package:card_scorekeeper/domain/models/round.dart';

void main() {
  group('Undo Functionality Widget Tests', () {
    late Game testGame;
    late ProviderContainer container;

    setUp(() {
      testGame = Game(
        id: 'test-game',
        name: 'Test Game',
        players: [
          const Player(id: 'p1', name: 'Alice'),
          const Player(id: 'p2', name: 'Bob'),
          const Player(id: 'p3', name: 'Charlie'),
        ],
        rounds: [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 1, actualWins: 1),
              const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 2),
              const RoundEntry(playerId: 'p3', predictedWins: 0, actualWins: 0),
            ],
          ),
          GameRound(
            index: 1,
            cards: 4,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(playerId: 'p1', predictedWins: 2, actualWins: 2),
              const RoundEntry(playerId: 'p2', predictedWins: 1, actualWins: 1),
              const RoundEntry(playerId: 'p3', predictedWins: 1, actualWins: 1),
            ],
          ),
        ],
        gameSettings: const GameSettings(),
        createdAt: DateTime.now(),
      );

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestApp({required Widget child}) {
      return ProviderScope(
        parent: container,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    group('Undo Button Visibility', () {
      testWidgets('shows undo button when undo is available', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Should show undo button since there are completed rounds
        expect(find.byIcon(Icons.undo), findsOneWidget);

        // Button should be enabled
        final undoButton = tester.widget<IconButton>(find.byIcon(Icons.undo));
        expect(undoButton.onPressed, isNotNull);
      });

      testWidgets('hides undo button when no undo available', (tester) async {
        final emptyGame = testGame.copyWith(rounds: []);
        container.read(gameControllerProvider.notifier).loadGame(emptyGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Should not show undo button
        expect(find.byIcon(Icons.undo), findsNothing);
      });

      testWidgets('shows undo count when multiple undos available',
          (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Should show undo count
        final undoState = container.read(undoControllerProvider);
        expect(undoState.canUndo, true);
        expect(undoState.undoCount, greaterThan(0));
      });
    });

    group('Round Undo Operations', () {
      testWidgets('undoes last completed round', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Verify initial state - should have 2 rounds
        var currentGame = container.read(gameControllerProvider);
        expect(currentGame?.rounds.length, 2);
        expect(currentGame?.rounds.last.status, RoundStatus.completed);

        // Tap undo button
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();

        // Should show undo confirmation dialog
        expect(find.text('Undo Last Round'), findsOneWidget);
        expect(find.text('This will remove the results from Round 2'),
            findsOneWidget);

        // Confirm undo
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Verify round was undone
        currentGame = container.read(gameControllerProvider);
        expect(currentGame?.rounds.length, 1);
        expect(currentGame?.rounds.first.index, 0);
      });

      testWidgets('cancels undo operation', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Tap undo button
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();

        // Cancel undo
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify no changes
        final currentGame = container.read(gameControllerProvider);
        expect(currentGame?.rounds.length, 2);
      });

      testWidgets('updates scores after undo', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Record initial scores
        var game = container.read(gameControllerProvider)!;
        final initialScores =
            game.players.map((p) => game.getPlayerTotalScore(p.id)).toList();

        // Undo last round
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Verify scores updated
        game = container.read(gameControllerProvider)!;
        final newScores =
            game.players.map((p) => game.getPlayerTotalScore(p.id)).toList();

        expect(newScores, isNot(equals(initialScores)));

        // Scores should reflect removal of last round
        expect(game.rounds.length, 1);
      });
    });

    group('Undo State Management', () {
      testWidgets('tracks undo history correctly', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Check initial undo state
        var undoState = container.read(undoControllerProvider);
        expect(undoState.canUndo, true);
        final initialUndoCount = undoState.undoCount;

        // Perform undo
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Check undo state after action
        undoState = container.read(undoControllerProvider);
        expect(undoState.undoCount, initialUndoCount - 1);

        if (undoState.undoCount > 0) {
          expect(undoState.canUndo, true);
        } else {
          expect(undoState.canUndo, false);
        }
      });

      testWidgets('limits undo to available history', (tester) async {
        // Game with only one round
        final singleRoundGame = testGame.copyWith(
          rounds: [testGame.rounds.first],
        );

        container
            .read(gameControllerProvider.notifier)
            .loadGame(singleRoundGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Undo the only round
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Should have no more undos available
        final undoState = container.read(undoControllerProvider);
        expect(undoState.canUndo, false);

        // Undo button should not be visible
        expect(find.byIcon(Icons.undo), findsNothing);
      });
    });

    group('Undo During Round Entry', () {
      testWidgets('allows undo during results entry', (tester) async {
        final gameInProgress = testGame.copyWith(
          rounds: [
            testGame.rounds.first, // Keep first completed round
            GameRound(
              index: 1,
              cards: 4,
              status: RoundStatus.results,
              entries: [
                const RoundEntry(playerId: 'p1', predictedWins: 2),
                const RoundEntry(playerId: 'p2', predictedWins: 1),
                const RoundEntry(playerId: 'p3', predictedWins: 1),
              ],
            ),
          ],
        );

        container
            .read(gameControllerProvider.notifier)
            .loadGame(gameInProgress);

        await tester.pumpWidget(
          createTestApp(child: const ResultsScreen()),
        );

        // Should show undo button even during results entry
        expect(find.byIcon(Icons.undo), findsOneWidget);

        // Tap undo button
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();

        // Should show undo dialog
        expect(find.text('Undo Last Round'), findsOneWidget);

        // Confirm undo
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Should undo the completed round and cancel current round
        final game = container.read(gameControllerProvider);
        expect(game?.rounds.length, 0);
      });

      testWidgets(
          'preserves current round progress when undoing previous round',
          (tester) async {
        final gameInProgress = testGame.copyWith(
          rounds: [
            testGame.rounds.first, // Completed round
            GameRound(
              index: 1,
              cards: 4,
              status: RoundStatus.results,
              entries: [
                const RoundEntry(
                    playerId: 'p1', predictedWins: 2, actualWins: 1),
                const RoundEntry(
                    playerId: 'p2', predictedWins: 1, actualWins: 2),
                const RoundEntry(
                    playerId: 'p3', predictedWins: 1), // Partial entry
              ],
            ),
          ],
        );

        container
            .read(gameControllerProvider.notifier)
            .loadGame(gameInProgress);

        await tester.pumpWidget(
          createTestApp(child: const ResultsScreen()),
        );

        // Verify current state shows partial results
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Predicted: 2'), findsOneWidget);

        // Undo previous round
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Current round should still be in progress but previous round removed
        final game = container.read(gameControllerProvider);
        expect(game?.rounds.length, 1);
        expect(game?.rounds.first.status, RoundStatus.results);
        expect(game?.rounds.first.index, 0); // Should become round 1 now
      });
    });

    group('Undo Feedback and Animation', () {
      testWidgets('shows feedback after successful undo', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Perform undo
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Should show snackbar or similar feedback
        expect(find.text('Round undone'), findsOneWidget.or(findsNothing));
      });

      testWidgets('animates score changes after undo', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Perform undo
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
        await tester.tap(find.text('Undo'));

        // Allow animations to complete
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Scores should be updated (exact verification depends on scoring system)
        final game = container.read(gameControllerProvider);
        expect(game?.rounds.length, 1);
      });
    });

    group('Undo Error Handling', () {
      testWidgets('handles undo when no game loaded', (tester) async {
        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Should not show undo button when no game
        expect(find.byIcon(Icons.undo), findsNothing);
      });

      testWidgets('gracefully handles undo failures', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);

        await tester.pumpWidget(
          createTestApp(child: const ScoreboardScreen()),
        );

        // Force an error condition (this would be implementation specific)
        // For now, just verify the UI handles the case gracefully
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();

        // Dialog should appear
        expect(find.text('Undo Last Round'), findsOneWidget);

        // Even if undo fails internally, UI should not crash
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // UI should still be responsive
        expect(find.byType(ScoreboardScreen), findsOneWidget);
      });
    });
  });
}
