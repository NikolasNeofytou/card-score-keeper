// test/widget/round_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_scorekeeper/ui/screens/predictions_screen.dart';
import 'package:card_scorekeeper/ui/screens/results_screen.dart';
import 'package:card_scorekeeper/ui/widgets/number_stepper.dart';
import 'package:card_scorekeeper/state/game_controller.dart';
import 'package:card_scorekeeper/state/providers.dart';
import 'package:card_scorekeeper/domain/models/game.dart';
import 'package:card_scorekeeper/domain/models/player.dart';
import 'package:card_scorekeeper/domain/models/round.dart';

void main() {
  group('Round Flow Widget Tests', () {
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
        rounds: [],
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

    group('Predictions Screen', () {
      testWidgets('displays all players for prediction entry', (tester) async {
        // Setup game with first round
        final gameWithRound = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.predictions,
              entries: [
                const RoundEntry(playerId: 'p1'),
                const RoundEntry(playerId: 'p2'),
                const RoundEntry(playerId: 'p3'),
              ],
            ),
          ],
        );

        // Override the game state
        container.read(gameControllerProvider.notifier).loadGame(gameWithRound);

        await tester.pumpWidget(
          createTestApp(child: const PredictionsScreen()),
        );

        // Verify all players are displayed
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Charlie'), findsOneWidget);

        // Verify round info is displayed
        expect(find.text('Round 1'), findsOneWidget);
        expect(find.text('3 cards'), findsOneWidget);

        // Verify stepper widgets for each player
        expect(find.byType(NumberStepper), findsNWidgets(3));
      });

      testWidgets('allows prediction entry and validation', (tester) async {
        final gameWithRound = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.predictions,
              entries: [
                const RoundEntry(playerId: 'p1'),
                const RoundEntry(playerId: 'p2'),
                const RoundEntry(playerId: 'p3'),
              ],
            ),
          ],
        );

        container.read(gameControllerProvider.notifier).loadGame(gameWithRound);

        await tester.pumpWidget(
          createTestApp(child: const PredictionsScreen()),
        );

        // Find first player's stepper
        final steppers = find.byType(NumberStepper);
        expect(steppers, findsNWidgets(3));

        // Tap the increment button for first player
        final firstStepper = steppers.first;
        final incrementButton = find.descendant(
          of: firstStepper,
          matching: find.byIcon(Icons.add),
        );

        await tester.tap(incrementButton);
        await tester.pump();

        // Verify the value increased
        expect(find.text('1'), findsWidgets);

        // Test maximum value constraint
        await tester.tap(incrementButton);
        await tester.tap(incrementButton);
        await tester.tap(incrementButton); // Should be at max (3)
        await tester.pump();

        // Try to go beyond maximum
        await tester.tap(incrementButton);
        await tester.pump();

        // Should still be at max
        expect(find.text('3'), findsWidgets);
      });

      testWidgets('shows validation errors for invalid predictions',
          (tester) async {
        final gameWithRound = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.predictions,
              entries: [
                const RoundEntry(playerId: 'p1'),
                const RoundEntry(playerId: 'p2'),
                const RoundEntry(playerId: 'p3'),
              ],
            ),
          ],
        );

        container.read(gameControllerProvider.notifier).loadGame(gameWithRound);

        await tester.pumpWidget(
          createTestApp(child: const PredictionsScreen()),
        );

        // Try to submit without filling predictions
        final submitButton = find.text('Continue to Results');
        expect(submitButton, findsOneWidget);

        await tester.tap(submitButton);
        await tester.pump();

        // Should show validation error
        expect(find.textContaining('prediction'), findsWidgets);
      });

      testWidgets('transitions to results screen when predictions complete',
          (tester) async {
        final gameWithRound = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.predictions,
              entries: [
                const RoundEntry(playerId: 'p1', predictedWins: 1),
                const RoundEntry(playerId: 'p2', predictedWins: 1),
                const RoundEntry(playerId: 'p3', predictedWins: 0),
              ],
            ),
          ],
        );

        container.read(gameControllerProvider.notifier).loadGame(gameWithRound);

        await tester.pumpWidget(
          createTestApp(
            child: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => const PredictionsScreen(),
                );
              },
            ),
          ),
        );

        // Submit predictions
        final submitButton = find.text('Continue to Results');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Should navigate to results screen
        expect(find.byType(ResultsScreen), findsOneWidget);
      });
    });

    group('Results Screen', () {
      testWidgets('displays prediction results for entry', (tester) async {
        final gameWithResults = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.results,
              entries: [
                const RoundEntry(playerId: 'p1', predictedWins: 1),
                const RoundEntry(playerId: 'p2', predictedWins: 1),
                const RoundEntry(playerId: 'p3', predictedWins: 0),
              ],
            ),
          ],
        );

        container
            .read(gameControllerProvider.notifier)
            .loadGame(gameWithResults);

        await tester.pumpWidget(
          createTestApp(child: const ResultsScreen()),
        );

        // Verify predictions are shown
        expect(find.text('Predicted: 1'), findsNWidgets(2));
        expect(find.text('Predicted: 0'), findsOneWidget);

        // Verify players are displayed
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Charlie'), findsOneWidget);

        // Verify actual results entry widgets
        expect(find.byType(NumberStepper), findsNWidgets(3));
      });

      testWidgets('validates actual results sum', (tester) async {
        final gameWithResults = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.results,
              entries: [
                const RoundEntry(playerId: 'p1', predictedWins: 1),
                const RoundEntry(playerId: 'p2', predictedWins: 1),
                const RoundEntry(playerId: 'p3', predictedWins: 0),
              ],
            ),
          ],
        );

        container
            .read(gameControllerProvider.notifier)
            .loadGame(gameWithResults);

        await tester.pumpWidget(
          createTestApp(child: const ResultsScreen()),
        );

        // Set invalid results (sum > cards)
        final steppers = find.byType(NumberStepper);

        // Set all to 2 (total 6, but cards is 3)
        for (int i = 0; i < 3; i++) {
          final stepper = steppers.at(i);
          final incrementButton = find.descendant(
            of: stepper,
            matching: find.byIcon(Icons.add),
          );

          await tester.tap(incrementButton);
          await tester.tap(incrementButton);
          await tester.pump();
        }

        // Try to submit
        final submitButton = find.text('Complete Round');
        await tester.tap(submitButton);
        await tester.pump();

        // Should show validation error
        expect(find.textContaining('sum'), findsWidgets);
      });

      testWidgets('completes round with valid results', (tester) async {
        final gameWithResults = testGame.copyWith(
          rounds: [
            GameRound(
              index: 0,
              cards: 3,
              status: RoundStatus.results,
              entries: [
                const RoundEntry(playerId: 'p1', predictedWins: 1),
                const RoundEntry(playerId: 'p2', predictedWins: 1),
                const RoundEntry(playerId: 'p3', predictedWins: 0),
              ],
            ),
          ],
        );

        container
            .read(gameControllerProvider.notifier)
            .loadGame(gameWithResults);

        await tester.pumpWidget(
          createTestApp(child: const ResultsScreen()),
        );

        // Set valid results
        final steppers = find.byType(NumberStepper);

        // Player 1: 1 win
        final stepper1 = steppers.at(0);
        final increment1 = find.descendant(
          of: stepper1,
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(increment1);

        // Player 2: 2 wins
        final stepper2 = steppers.at(1);
        final increment2 = find.descendant(
          of: stepper2,
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(increment2);
        await tester.tap(increment2);

        // Player 3: 0 wins (default)

        await tester.pump();

        // Submit round
        final submitButton = find.text('Complete Round');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Verify round is completed in game state
        final currentGame = container.read(gameControllerProvider);
        expect(currentGame?.rounds.first.status, RoundStatus.completed);
        expect(currentGame?.rounds.first.entries[0].actualWins, 1);
        expect(currentGame?.rounds.first.entries[1].actualWins, 2);
        expect(currentGame?.rounds.first.entries[2].actualWins, 0);
      });
    });

    group('Round Navigation Flow', () {
      testWidgets('flows through complete round cycle', (tester) async {
        container.read(gameControllerProvider.notifier).loadGame(testGame);
        container.read(gameControllerProvider.notifier).startNextRound();

        await tester.pumpWidget(
          createTestApp(
            child: Navigator(
              initialRoute: '/predictions',
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case '/predictions':
                    return MaterialPageRoute(
                      builder: (context) => const PredictionsScreen(),
                    );
                  case '/results':
                    return MaterialPageRoute(
                      builder: (context) => const ResultsScreen(),
                    );
                  default:
                    return MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        body: Center(child: Text('Not Found')),
                      ),
                    );
                }
              },
            ),
          ),
        );

        // Start in predictions screen
        expect(find.byType(PredictionsScreen), findsOneWidget);

        // Enter predictions
        final steppers = find.byType(NumberStepper);
        for (int i = 0; i < 3; i++) {
          final stepper = steppers.at(i);
          final increment = find.descendant(
            of: stepper,
            matching: find.byIcon(Icons.add),
          );
          await tester.tap(increment);
        }
        await tester.pump();

        // Continue to results
        final continueButton = find.text('Continue to Results');
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        // Should be in results screen
        expect(find.byType(ResultsScreen), findsOneWidget);

        // Enter results (ensure sum equals cards)
        final resultSteppers = find.byType(NumberStepper);

        // Set first player to 3 wins, others to 0
        final firstStepper = resultSteppers.first;
        final firstIncrement = find.descendant(
          of: firstStepper,
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(firstIncrement);
        await tester.tap(firstIncrement);
        await tester.tap(firstIncrement);
        await tester.pump();

        // Complete round
        final completeButton = find.text('Complete Round');
        await tester.tap(completeButton);
        await tester.pumpAndSettle();

        // Verify game state updated
        final game = container.read(gameControllerProvider);
        expect(game?.rounds.length, 1);
        expect(game?.rounds.first.status, RoundStatus.completed);
      });
    });
  });
}
