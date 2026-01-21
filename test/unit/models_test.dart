import 'package:test/test.dart';
import 'package:card_scorekeeper/domain/models/game.dart';
import 'package:card_scorekeeper/domain/models/player.dart';

void main() {
  group('Game Model Tests', () {
    test('should create a game with players', () {
      final players = [
        Player(id: '1', name: 'Player 1'),
        Player(id: '2', name: 'Player 2'),
      ];

      final game = Game(
        id: 'game1',
        name: 'Test Game',
        players: players,
        createdAt: DateTime.now(),
      );

      expect(game.players.length, 2);
      expect(game.name, 'Test Game');
    });
  });
}
