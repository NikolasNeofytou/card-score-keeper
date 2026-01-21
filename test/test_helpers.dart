// test/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_scorekeeper/domain/models/game.dart';
import 'package:card_scorekeeper/domain/models/player.dart';
import 'package:card_scorekeeper/domain/models/round.dart';
import 'package:card_scorekeeper/state/providers.dart';

/// Test helpers and utilities for consistent test setup across the app
class TestHelpers {
  /// Creates a test app wrapper with Riverpod providers
  static Widget createTestApp({
    required Widget child,
    ProviderContainer? container,
    List<Override>? overrides,
  }) {
    return ProviderScope(
      parent: container,
      overrides: overrides ?? [],
      child: MaterialApp(
        home: child,
        theme: ThemeData.light(),
      ),
    );
  }

  /// Creates a test app with navigation support
  static Widget createTestAppWithNavigation({
    required Widget child,
    ProviderContainer? container,
    List<Override>? overrides,
    String initialRoute = '/',
    Map<String, WidgetBuilder>? routes,
  }) {
    return ProviderScope(
      parent: container,
      overrides: overrides ?? [],
      child: MaterialApp(
        home: child,
        initialRoute: initialRoute,
        routes: routes ?? {},
        theme: ThemeData.light(),
      ),
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

  /// Scrolls to find a widget if it's not visible
  static Future<void> scrollToFind(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
  }) async {
    if (finder.evaluate().isNotEmpty) return;

    final scrollFinder = scrollable ?? find.byType(Scrollable);
    if (scrollFinder.evaluate().isEmpty) return;

    await tester.scrollUntilVisible(
      finder,
      100.0,
      scrollable: scrollFinder,
    );
  }
}

/// Sample test data for consistent testing
class TestData {
  /// Creates a basic 3-player game
  static Game createBasicGame() {
    return Game(
      id: 'test-game-1',
      name: 'Test Game',
      players: createPlayers(3),
      rounds: [],
      gameSettings: const GameSettings(),
      createdAt: DateTime(2024, 1, 1),
    );
  }

  /// Creates a game with specified number of players
  static Game createGameWithPlayers(int playerCount) {
    return Game(
      id: 'test-game-$playerCount',
      name: 'Test Game $playerCount Players',
      players: createPlayers(playerCount),
      rounds: [],
      gameSettings: const GameSettings(),
      createdAt: DateTime.now(),
    );
  }

  /// Creates a completed game with multiple rounds
  static Game createCompletedGame() {
    final players = createPlayers(3);

    return Game(
      id: 'completed-game',
      name: 'Completed Test Game',
      players: players,
      rounds: [
        GameRound(
          index: 0,
          cards: 3,
          status: RoundStatus.completed,
          entries: [
            const RoundEntry(
                playerId: 'player-1', predictedWins: 1, actualWins: 1),
            const RoundEntry(
                playerId: 'player-2', predictedWins: 1, actualWins: 2),
            const RoundEntry(
                playerId: 'player-3', predictedWins: 1, actualWins: 0),
          ],
        ),
        GameRound(
          index: 1,
          cards: 4,
          status: RoundStatus.completed,
          entries: [
            const RoundEntry(
                playerId: 'player-1', predictedWins: 2, actualWins: 2),
            const RoundEntry(
                playerId: 'player-2', predictedWins: 1, actualWins: 1),
            const RoundEntry(
                playerId: 'player-3', predictedWins: 1, actualWins: 1),
          ],
        ),
      ],
      gameSettings: const GameSettings(),
      createdAt: DateTime.now(),
    );
  }

  /// Creates a game in progress with predictions
  static Game createGameInProgress() {
    return Game(
      id: 'in-progress-game',
      name: 'In Progress Game',
      players: createPlayers(3),
      rounds: [
        GameRound(
          index: 0,
          cards: 3,
          status: RoundStatus.results,
          entries: [
            const RoundEntry(playerId: 'player-1', predictedWins: 1),
            const RoundEntry(playerId: 'player-2', predictedWins: 1),
            const RoundEntry(playerId: 'player-3', predictedWins: 0),
          ],
        ),
      ],
      gameSettings: const GameSettings(),
      createdAt: DateTime.now(),
    );
  }

  /// Creates a list of test players
  static List<Player> createPlayers(int count) {
    final names = [
      'Alice',
      'Bob',
      'Charlie',
      'Diana',
      'Eve',
      'Frank',
      'Grace',
      'Henry',
      'Ivy',
      'Jack',
      'Kelly',
      'Liam'
    ];

    return List.generate(
      count,
      (index) => Player(
        id: 'player-${index + 1}',
        name: names[index % names.length],
      ),
    );
  }

  /// Creates a round with specified parameters
  static GameRound createRound({
    required int index,
    required int cards,
    required List<String> playerIds,
    RoundStatus status = RoundStatus.predictions,
    Map<String, int>? predictions,
    Map<String, int>? results,
  }) {
    return GameRound(
      index: index,
      cards: cards,
      status: status,
      entries: playerIds
          .map((playerId) => RoundEntry(
                playerId: playerId,
                predictedWins: predictions?[playerId],
                actualWins: results?[playerId],
              ))
          .toList(),
    );
  }

  /// Creates edge case scenarios for testing
  static List<Game> createEdgeCaseGames() {
    return [
      // Minimum players
      createGameWithPlayers(3),

      // Maximum players
      createGameWithPlayers(6),

      // Game with no rounds
      createBasicGame(),

      // Game with all zero scores
      Game(
        id: 'zero-score-game',
        name: 'Zero Score Game',
        players: createPlayers(3),
        rounds: [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(
                  playerId: 'player-1', predictedWins: 0, actualWins: 0),
              const RoundEntry(
                  playerId: 'player-2', predictedWins: 0, actualWins: 0),
              const RoundEntry(
                  playerId: 'player-3', predictedWins: 0, actualWins: 3),
            ],
          ),
        ],
        gameSettings: const GameSettings(),
        createdAt: DateTime.now(),
      ),

      // Game with perfect predictions
      Game(
        id: 'perfect-game',
        name: 'Perfect Predictions Game',
        players: createPlayers(3),
        rounds: [
          GameRound(
            index: 0,
            cards: 3,
            status: RoundStatus.completed,
            entries: [
              const RoundEntry(
                  playerId: 'player-1', predictedWins: 1, actualWins: 1),
              const RoundEntry(
                  playerId: 'player-2', predictedWins: 1, actualWins: 1),
              const RoundEntry(
                  playerId: 'player-3', predictedWins: 1, actualWins: 1),
            ],
          ),
        ],
        gameSettings: const GameSettings(),
        createdAt: DateTime.now(),
      ),
    ];
  }
}

/// Mock providers for testing
class MockProviders {
  /// Creates a game controller override with test data
  static Override gameControllerOverride(Game game) {
    return gameControllerProvider.overrideWith((ref) {
      final controller = GameController(ref.watch(gameRepositoryProvider));
      controller.loadGame(game);
      return controller;
    });
  }

  /// Creates a game repository override with in-memory storage
  static Override gameRepositoryOverride() {
    return gameRepositoryProvider.overrideWith((ref) {
      // Return a mock repository for testing
      return MockGameRepository();
    });
  }
}

/// Mock repository for testing
class MockGameRepository {
  final Map<String, Game> _games = {};
  final List<Game> _gameList = [];

  Future<void> saveGame(Game game) async {
    _games[game.id] = game;
    if (!_gameList.any((g) => g.id == game.id)) {
      _gameList.add(game);
    }
  }

  Future<Game?> loadGame(String gameId) async {
    return _games[gameId];
  }

  Future<List<Game>> loadAllGames() async {
    return List.from(_gameList);
  }

  Future<void> deleteGame(String gameId) async {
    _games.remove(gameId);
    _gameList.removeWhere((g) => g.id == gameId);
  }

  Future<void> clear() async {
    _games.clear();
    _gameList.clear();
  }
}

/// Extensions for more readable tests
extension GameTestExtensions on Game {
  /// Gets the total score for a player
  int getPlayerScore(String playerId) {
    int totalScore = 0;
    for (final round in rounds) {
      if (round.status == RoundStatus.completed) {
        final entry = round.entries.firstWhere(
          (e) => e.playerId == playerId,
        );

        // Calculate score based on prediction accuracy
        final predicted = entry.predictedWins ?? 0;
        final actual = entry.actualWins ?? 0;

        if (predicted == actual) {
          totalScore += 10 + actual; // Bonus for correct prediction
        } else {
          totalScore -=
              (predicted - actual).abs(); // Penalty for wrong prediction
        }
      }
    }
    return totalScore;
  }

  /// Checks if the game is valid
  bool isValid() {
    if (players.length < 3 || players.length > 6) return false;

    for (final round in rounds) {
      if (round.entries.length != players.length) return false;

      if (round.status == RoundStatus.completed) {
        final totalActual =
            round.entries.map((e) => e.actualWins ?? 0).reduce((a, b) => a + b);

        if (totalActual != round.cards) return false;
      }
    }

    return true;
  }
}

/// Test matchers for more expressive assertions
class GameMatchers {
  /// Matches a game with specified number of players
  static Matcher hasPlayerCount(int count) {
    return predicate<Game>(
      (game) => game.players.length == count,
      'has $count players',
    );
  }

  /// Matches a game with specified number of rounds
  static Matcher hasRoundCount(int count) {
    return predicate<Game>(
      (game) => game.rounds.length == count,
      'has $count rounds',
    );
  }

  /// Matches a completed game
  static Matcher isCompleted() {
    return predicate<Game>(
      (game) =>
          game.rounds.isNotEmpty &&
          game.rounds.every((r) => r.status == RoundStatus.completed),
      'is completed',
    );
  }

  /// Matches a game in progress
  static Matcher isInProgress() {
    return predicate<Game>(
      (game) =>
          game.rounds.isNotEmpty &&
          game.rounds.any((r) => r.status != RoundStatus.completed),
      'is in progress',
    );
  }
}
