// Comprehensive widget tests focusing on Material Design components
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

  group('Comprehensive Widget Tests', () {
    group('Widget Integration Tests', () {
      testWidgets('Common widgets render correctly', (tester) async {
        // Test basic widget rendering without providers
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: const Column(
                children: [
                  Text('Hello World'),
                  ElevatedButton(onPressed: null, child: Text('Button')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Hello World'), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Screen Rendering Tests', () {
      testWidgets('CreateGameScreen renders successfully', (tester) async {
        await tester.pumpWidget(createTestApp(const CreateGameScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(CreateGameScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('GameListScreen renders successfully', (tester) async {
        await tester.pumpWidget(createTestApp(const GameListScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(GameListScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Basic Functionality Tests', () {
      testWidgets('Material Design components work', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test App')),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Material Design Test'),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Card Content'),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.add),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Material Design Test'), findsOneWidget);
        expect(find.text('Card Content'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });
    });
  });
}
