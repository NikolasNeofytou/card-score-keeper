// test/widget/screen_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui/screens/create_game_screen.dart';
import '../../lib/ui/screens/game_list_screen.dart';
import 'test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group('Screen Widget Tests', () {
    group('Create Game Screen', () {
      testWidgets('renders without crashing', (tester) async {
        await tester.pumpWidget(createTestApp(const CreateGameScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(CreateGameScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has essential UI elements', (tester) async {
        await tester.pumpWidget(createTestApp(const CreateGameScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Game List Screen', () {
      testWidgets('renders without crashing', (tester) async {
        await tester.pumpWidget(createTestApp(const GameListScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(GameListScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('has Material Design structure', (tester) async {
        await tester.pumpWidget(createTestApp(const GameListScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Basic UI Structure', () {
      testWidgets('Non-animated screens have Material Design structure',
          (tester) async {
        // Test screens without animations to avoid timer issues
        await tester.pumpWidget(createTestApp(const CreateGameScreen()));
        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);

        await tester.pumpWidget(createTestApp(const GameListScreen()));
        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
