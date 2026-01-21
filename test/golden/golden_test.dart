// test/golden/golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_scorekeeper/ui/screens/home_screen.dart';
import 'package:card_scorekeeper/ui/screens/create_game_screen.dart';
import 'package:card_scorekeeper/ui/widgets/leaderboard_table.dart';
import 'package:card_scorekeeper/ui/widgets/number_stepper.dart';
import '../mocks/test_data.dart';

void main() {
  group('Golden File Tests', () {
    testWidgets('HomeScreen golden test', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('golden/home_screen.png'),
      );
    });

    testWidgets('CreateGameScreen golden test', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const CreateGameScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(CreateGameScreen),
        matchesGoldenFile('golden/create_game_screen.png'),
      );
    });

    testWidgets('LeaderboardTable golden test', (tester) async {
      final game = TestDataFactory.createCompleteGame();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: LeaderboardTable(
              players: game.players,
              rounds: game.rounds,
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(LeaderboardTable),
        matchesGoldenFile('golden/leaderboard_table.png'),
      );
    });

    testWidgets('NumberStepper golden test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Center(
              child: NumberStepper(
                value: 5,
                min: 0,
                max: 10,
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(NumberStepper),
        matchesGoldenFile('golden/number_stepper.png'),
      );
    });

    group('Theme Variations', () {
      testWidgets('Dark theme golden test', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const HomeScreen(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(HomeScreen),
          matchesGoldenFile('golden/home_screen_dark.png'),
        );
      });

      testWidgets('High contrast theme golden test', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                  secondary: Colors.white,
                ),
              ),
              home: const HomeScreen(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(HomeScreen),
          matchesGoldenFile('golden/home_screen_high_contrast.png'),
        );
      });
    });

    group('Responsive Layout Tests', () {
      testWidgets('Mobile layout golden test', (tester) async {
        // Set mobile screen size
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const HomeScreen(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(HomeScreen),
          matchesGoldenFile('golden/home_screen_mobile.png'),
        );
      });

      testWidgets('Tablet layout golden test', (tester) async {
        // Set tablet screen size
        await tester.binding.setSurfaceSize(const Size(768, 1024));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const HomeScreen(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(HomeScreen),
          matchesGoldenFile('golden/home_screen_tablet.png'),
        );
      });
    });
  });
}
