// test/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers and utilities for consistent test setup across the app
class TestHelpers {
  /// Creates a test app wrapper
  static Widget createTestApp({
    required Widget child,
  }) {
    return MaterialApp(
      home: child,
      theme: ThemeData.light(),
    );
  }

  /// Creates a test app with navigation support
  static Widget createTestAppWithNavigation({
    required Widget child,
    String initialRoute = '/',
    Map<String, WidgetBuilder>? routes,
  }) {
    return MaterialApp(
      home: child,
      initialRoute: initialRoute,
      routes: routes ?? {},
      theme: ThemeData.light(),
    );
  }

  /// Waits for all animations and async operations to complete
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, [
    Duration timeout = const Duration(seconds: 10),
  ]) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Finds a widget by its key
  static Finder findByTestKey(String key) {
    return find.byKey(Key(key));
  }

  /// Finds text that contains a substring (case insensitive)
  static Finder findTextContaining(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data?.toLowerCase().contains(text.toLowerCase()) == true,
    );
  }

  /// Enters text into a text field identified by key
  static Future<void> enterTextByKey(
    WidgetTester tester,
    String key,
    String text,
  ) async {
    await tester.enterText(findByTestKey(key), text);
    await tester.pump();
  }

  /// Taps a widget and waits for animations
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}

/// Sample test data for consistent testing
class TestData {
  /// Creates basic test values
  static Map<String, dynamic> createBasicTestData() {
    return {
      'testString': 'Test Value',
      'testInt': 42,
      'testDouble': 3.14,
      'testBool': true,
      'testList': [1, 2, 3],
      'testMap': {'key': 'value'},
    };
  }

  /// Creates test user data
  static Map<String, String> createTestUsers(int count) {
    final names = [
      'Alice',
      'Bob',
      'Charlie',
      'Diana',
      'Eve',
      'Frank',
    ];

    final users = <String, String>{};
    for (int i = 0; i < count && i < names.length; i++) {
      users['user_${i + 1}'] = names[i];
    }
    return users;
  }
}

/// Test matchers for more expressive assertions
class TestMatchers {
  /// Matches a value within a range
  static Matcher isInRange(num min, num max) {
    return predicate<num>(
      (value) => value >= min && value <= max,
      'is between $min and $max',
    );
  }

  /// Matches a positive number
  static Matcher isPositive() {
    return predicate<num>(
      (value) => value > 0,
      'is positive',
    );
  }
}
