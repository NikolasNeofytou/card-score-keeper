// test/mocks/test_data.dart
import 'package:card_scorekeeper/domain/models/game.dart';
import 'package:card_scorekeeper/domain/models/player.dart';
import 'package:card_scorekeeper/domain/models/round.dart';

/// Test data factory for creating consistent test objects
class TestData {
  // Sample players for testing
  static final twoPlayerList = [
    const Player(
      id: 'player1',
      name: 'Alice',
    ),
    const Player(
      id: 'player2',
      name: 'Bob',
    ),
  ];

  static final threePlayerList = twoPlayerList +
      [
        const Player(
          id: 'player3',
          name: 'Charlie',
        ),
      ];

  static final fourPlayerList = threePlayerList +
      [
        const Player(
          id: 'player4',
          name: 'Diana',
        ),
      ];

  // Sample game settings
  static GameSettings createSampleSettings({
    int peakCards = 3,
    int bonusExact = 1,
  }) {
    return GameSettings(
      peakCards: peakCards,
      bonusExact: bonusExact,
    );
  }

  // Sample game
  static Game createSampleGame({
    String? id,
    String? name,
    List<Player>? players,
    GameSettings? settings,
    List<GameRound>? rounds,
    GameState state = GameState.prediction,
    int? currentRoundIndex,
  }) {
    return Game(
      id: id ?? 'game1',
      name: name ?? 'Test Game',
      players: players ?? twoPlayerList,
      settings: settings ?? createSampleSettings(),
      createdAt: DateTime(2024, 1, 1),
      lastModified: DateTime(2024, 1, 1),
      currentRoundIndex: currentRoundIndex ?? 0,
      state: state,
      rounds: rounds ?? [],
    );
  }

  // Sample round
  static GameRound createSampleRound({
    int index = 0,
    int cards = 3,
    RoundStatus status = RoundStatus.empty,
    List<RoundEntry>? entries,
  }) {
    return GameRound(
      index: index,
      cards: cards,
      status: status,
      entries: entries ??
          [
            const RoundEntry(
                playerId: 'player1', predictedWins: 2, actualWins: 2),
            const RoundEntry(
                playerId: 'player2', predictedWins: 1, actualWins: 1),
          ],
    );
  }

  /// Create game in progress
  static Game gameInProgress() {
    return createSampleGame(
      state: GameState.scoring,
      rounds: [
        createSampleRound(
          index: 0,
          cards: 3,
          status: RoundStatus.completed,
        ),
        createSampleRound(
          index: 1,
          cards: 4,
          status: RoundStatus.predictionsSet,
        ),
      ],
      currentRoundIndex: 1,
    );
  }

  /// Create finished game
  static Game finishedGame() {
    return createSampleGame(
      state: GameState.finished,
      rounds: [
        createSampleRound(index: 0, cards: 3, status: RoundStatus.completed),
        createSampleRound(index: 1, cards: 4, status: RoundStatus.completed),
        createSampleRound(index: 2, cards: 5, status: RoundStatus.completed),
      ],
      currentRoundIndex: 2,
    );
  }

  /// Create game with edge case settings
  static Game gameWithEdgeSettings() {
    return createSampleGame(
      settings: createSampleSettings(peakCards: 10, bonusExact: 5),
    );
  }

  /// Generate large list of players for performance testing
  static List<Player> generateLargePlayers(int count) {
    return List.generate(
      count,
      (index) => Player(
        id: 'player_$index',
        name: 'Player $index',
      ),
    );
  }

  /// Game state variations for testing
  static List<Game> gameStateVariations() {
    return [
      createSampleGame(state: GameState.prediction),
      createSampleGame(state: GameState.scoring),
      createSampleGame(state: GameState.finished),
    ];
  }

  /// Large game for performance testing
  static Game largeGame() {
    final players = generateLargePlayers(6);
    final rounds = List.generate(
      15,
      (index) => GameRound(
        index: index,
        cards: 3 + (index % 5),
        status: RoundStatus.completed,
        entries: players
            .map((p) => RoundEntry(
                  playerId: p.id,
                  predictedWins: index % 3,
                  actualWins: index % 3,
                ))
            .toList(),
      ),
    );

    return Game(
      id: 'large_game',
      name: 'Performance Test Game',
      players: players,
      settings: createSampleSettings(),
      createdAt: DateTime(2024, 1, 1),
      lastModified: DateTime(2024, 1, 1),
      currentRoundIndex: 14,
      state: GameState.finished,
      rounds: rounds,
    );
  }
}
