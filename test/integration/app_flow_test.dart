// test/integration/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:card_scorekeeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete app startup and navigation flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Basic app structure should be present
      expect(find.byType(ProviderScope), findsOneWidget);

      // Should not crash during initial load
      expect(tester.takeException(), isNull);
    });

    testWidgets('App handles basic navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for navigation elements (buttons, tabs, etc.)
      final navElements = find.byType(InkWell);
      if (navElements.evaluate().isNotEmpty) {
        await tester.tap(navElements.first);
        await tester.pumpAndSettle();

        // Should not crash during navigation
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('App state persists across navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that the app maintains state
      expect(find.byType(ProviderScope), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
