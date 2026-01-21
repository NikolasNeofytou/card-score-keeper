import 'package:flutter_test/flutter_test.dart';
import 'package:card_scorekeeper/domain/models/game.dart';
import 'package:card_scorekeeper/domain/models/player.dart';
import 'package:card_scorekeeper/domain/models/round.dart';
import '../mocks/test_data.dart';

void main() {
  group('Domain Models Tests', () {
    group('GameSettings', () {
      test('can be created with required parameters', () {
        const settings = GameSettings(
          peakCards: 6,
          bonusExact: 5,
        );

        expect(settings.peakCards, 6);
        expect(settings.bonusExact, 5);
      });

      test('can be serialized to JSON', () {
        const settings = GameSettings(peakCards: 10, bonusExact: 5);
        final json = settings.toJson();

        expect(json['peakCards'], 10);
        expect(json['bonusExact'], 5);
      });

      test('can be deserialized from JSON', () {
        final json = {'peakCards': 8, 'bonusExact': 3};
        final settings = GameSettings.fromJson(json);

        expect(settings.peakCards, 8);
        expect(settings.bonusExact, 3);
      });
    });

    group('Player', () {
      test('can be created with ID and name', () {
        const player = Player(id: '1', name: 'Alice');

        expect(player.id, '1');
        expect(player.name, 'Alice');
      });

      test('can be serialized to JSON', () {
        const player = Player(id: '2', name: 'Bob');
        final json = player.toJson();

        expect(json['id'], '2');
        expect(json['name'], 'Bob');
      });

      test('can be deserialized from JSON', () {
        final json = {'id': '3', 'name': 'Charlie'};
        final player = Player.fromJson(json);

        expect(player.id, '3');
        expect(player.name, 'Charlie');
      });
    });

    group('GameRound', () {
      test('can be created with all required parameters', () {
        final round = GameRound(
          index: 1,
          cards: 3,
          status: RoundStatus.empty,
          entries: [
            const RoundEntry(playerId: '1'),
            const RoundEntry(playerId: '2'),
          ],
        );

        expect(round.index, 1);
        expect(round.cards, 3);
        expect(round.status, RoundStatus.empty);
        expect(round.entries.length, 2);
      });

      test('can track round progression through states', () {
        const emptyRound = GameRound(
          index: 0,
          cards: 2,
          status: RoundStatus.empty,
          entries: [],
        );

        final withPredictions = emptyRound.copyWith(
          status: RoundStatus.predictionsSet,
        );

        final completed = withPredictions.copyWith(
          status: RoundStatus.completed,
        );

        expect(emptyRound.status, RoundStatus.empty);
        expect(withPredictions.status, RoundStatus.predictionsSet);
        expect(completed.status, RoundStatus.completed);
      });
    });

    group('Game', () {
      test('can be created with all required parameters', () {
        final game = TestData.createSampleGame();

        expect(game.id, 'game1');
        expect(game.name, 'Test Game');
        expect(game.settings.peakCards, 3);
        expect(game.players.length, 2);
        expect(game.rounds.length, 0);
        expect(game.currentRoundIndex, 0);
        expect(game.state, GameState.prediction);
      });

      test('can track game state progression', () {
        final game = TestData.createSampleGame();

        expect(game.state, GameState.prediction);

        final scoringGame = game.copyWith(state: GameState.scoring);
        expect(scoringGame.state, GameState.scoring);

        final finishedGame = scoringGame.copyWith(state: GameState.finished);
        expect(finishedGame.state, GameState.finished);
      });

      test('can handle player management', () {
        final game =
            TestData.createSampleGame(players: TestData.fourPlayerList);

        expect(game.players.length, 4);
        expect(game.players.first.name, 'Alice');
        expect(game.players.last.name, 'Diana');
      });

      test('can manage multiple rounds', () {
        final game = TestData.gameInProgress();

        expect(game.rounds.length, 2);
        expect(game.rounds[0].status, RoundStatus.completed);
        expect(game.rounds[1].status, RoundStatus.predictionsSet);
        expect(game.currentRoundIndex, 1);
      });
    });

    group('RoundEntry', () {
      test('can be created with player ID only', () {
        const entry = RoundEntry(playerId: '1');

        expect(entry.playerId, '1');
        expect(entry.predictedWins, null);
        expect(entry.actualWins, null);
      });

      test('can track predictions and actual wins', () {
        const entry = RoundEntry(
          playerId: '1',
          predictedWins: 2,
          actualWins: 3,
        );

        expect(entry.playerId, '1');
        expect(entry.predictedWins, 2);
        expect(entry.actualWins, 3);
      });

      test('can be updated with copyWith', () {
        const entry = RoundEntry(playerId: '1');

        final withPrediction = entry.copyWith(predictedWins: 2);
        expect(withPrediction.predictedWins, 2);
        expect(withPrediction.actualWins, null);

        final withActual = withPrediction.copyWith(actualWins: 1);
        expect(withActual.predictedWins, 2);
        expect(withActual.actualWins, 1);
      });

      test('supports JSON serialization', () {
        const entry = RoundEntry(
          playerId: '1',
          predictedWins: 2,
          actualWins: 1,
        );

        final json = entry.toJson();
        expect(json['playerId'], '1');
        expect(json['predictedWins'], 2);
        expect(json['actualWins'], 1);

        final fromJson = RoundEntry.fromJson(json);
        expect(fromJson.playerId, entry.playerId);
        expect(fromJson.predictedWins, entry.predictedWins);
        expect(fromJson.actualWins, entry.actualWins);
      });
    });

    group('Edge Cases and Validation', () {
      test('handles games with minimum settings', () {
        final game = TestData.gameWithEdgeSettings();

        expect(game.settings.peakCards, 10);
        expect(game.settings.bonusExact, 5);
        expect(game.players.length, 2);
      });

      test('handles finished game state', () {
        final game = TestData.finishedGame();

        expect(game.state, GameState.finished);
        expect(
            game.rounds.every((r) => r.status == RoundStatus.completed), true);
      });

      test('handles large player counts', () {
        final players = TestData.generateLargePlayers(50);
        expect(players.length, 50);
        expect(players.first.id, 'player_0');
        expect(players.last.id, 'player_49');
      });

      test('game copyWith preserves original state when no changes', () {
        final original = TestData.createSampleGame();
        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.name, original.name);
        expect(copied.state, original.state);
        expect(copied.players, original.players);
      });
    });
  });
}
