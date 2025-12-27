import 'package:test/test.dart';
import 'package:tichu_engine/tichu_engine.dart';

void main() {
  group('DeckFactory', () {
    test('creates standard 56-card deck', () {
      final deck = DeckFactory.createDeck();

      expect(deck.length, equals(56));

      // Count regular cards (52)
      final regularCards = deck.where((c) => c.isRegular).toList();
      expect(regularCards.length, equals(52));

      // Count special cards (4)
      final specialCards = deck.where((c) => c.isSpecial).toList();
      expect(specialCards.length, equals(4));

      // Verify all 4 special cards present
      expect(
        specialCards.any((c) => c.special == SpecialCard.mahjong),
        isTrue,
      );
      expect(
        specialCards.any((c) => c.special == SpecialCard.dog),
        isTrue,
      );
      expect(
        specialCards.any((c) => c.special == SpecialCard.phoenix),
        isTrue,
      );
      expect(
        specialCards.any((c) => c.special == SpecialCard.dragon),
        isTrue,
      );

      // Verify all suits and ranks present
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          expect(
            regularCards.any((c) => c.suit == suit && c.rank == rank),
            isTrue,
            reason: 'Missing ${rank.display} of ${suit.name}',
          );
        }
      }
    });

    test('shuffles deck randomly', () {
      final deck1 = DeckFactory.createDeck();
      final deck2 = DeckFactory.createDeck();

      final shuffled1 = DeckFactory.shuffleDeck(deck1);
      final shuffled2 = DeckFactory.shuffleDeck(deck2);

      // Shuffled decks should differ
      expect(shuffled1, isNot(equals(shuffled2)));

      // But should have same cards
      expect(shuffled1.length, equals(56));
      expect(shuffled2.length, equals(56));
    });

    test('deals 14 cards to each of 4 players', () {
      final deck = DeckFactory.shuffleDeck(DeckFactory.createDeck());
      final hands = DeckFactory.dealCards(deck);

      expect(hands.length, equals(4));
      expect(hands[0]!.length, equals(14));
      expect(hands[1]!.length, equals(14));
      expect(hands[2]!.length, equals(14));
      expect(hands[3]!.length, equals(14));

      // All cards dealt
      final totalCards = hands.values.fold<int>(
        0,
        (sum, hand) => sum + hand.length,
      );
      expect(totalCards, equals(56));
    });

    test('sorts hand by suit and rank', () {
      final hand = [
        const TichuCard.regular(suit: Suit.jade, rank: Rank.ace),
        const TichuCard.special(special: SpecialCard.phoenix),
        const TichuCard.regular(suit: Suit.jade, rank: Rank.two),
        const TichuCard.special(special: SpecialCard.dragon),
        const TichuCard.regular(suit: Suit.sword, rank: Rank.king),
      ];

      final sorted = DeckFactory.sortHand(hand);

      // Special cards first
      expect(sorted[0].isSpecial, isTrue);
      expect(sorted[1].isSpecial, isTrue);

      // Then regular cards by suit and rank
      expect(sorted[2].suit, equals(Suit.jade));
      expect(sorted[2].rank, equals(Rank.two));
    });
  });

  group('TichuCard', () {
    test('calculates point values correctly', () {
      // 5 = 5 points
      expect(
        const TichuCard.regular(suit: Suit.jade, rank: Rank.five).pointValue,
        equals(5),
      );

      // 10 = 10 points
      expect(
        const TichuCard.regular(suit: Suit.sword, rank: Rank.ten).pointValue,
        equals(10),
      );

      // K = 10 points
      expect(
        const TichuCard.regular(suit: Suit.pagoda, rank: Rank.king).pointValue,
        equals(10),
      );

      // Dragon = 25 points
      expect(
        const TichuCard.special(special: SpecialCard.dragon).pointValue,
        equals(25),
      );

      // Phoenix = -25 points
      expect(
        const TichuCard.special(special: SpecialCard.phoenix).pointValue,
        equals(-25),
      );

      // Regular card = 0 points
      expect(
        const TichuCard.regular(suit: Suit.star, rank: Rank.three).pointValue,
        equals(0),
      );
    });

    test('serializes to/from JSON', () {
      const card = TichuCard.regular(suit: Suit.jade, rank: Rank.ace);
      final json = card.toJson();
      final restored = TichuCard.fromJson(json);

      expect(restored, equals(card));
      expect(restored.suit, equals(Suit.jade));
      expect(restored.rank, equals(Rank.ace));
    });

    test('special card serialization', () {
      const card = TichuCard.special(special: SpecialCard.dragon);
      final json = card.toJson();
      final restored = TichuCard.fromJson(json);

      expect(restored, equals(card));
      expect(restored.special, equals(SpecialCard.dragon));
      expect(restored.isSpecial, isTrue);
    });
  });

  group('ScoringService', () {
    late TichuRuleset ruleset;
    late ScoringService scoringService;

    setUp(() {
      ruleset = TichuRuleset.standard();
      scoringService = ScoringService(ruleset);
    });

    test('calculates basic card points', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            wonCards: [
              const TichuCard.regular(suit: Suit.jade, rank: Rank.five),
              const TichuCard.regular(suit: Suit.sword, rank: Rank.ten),
            ],
            finishPosition: 1,
            hasFinished: true,
          ),
          PlayerState(
            id: '1',
            name: 'Player 1',
            wonCards: [],
            finishPosition: 2,
            hasFinished: true,
          ),
          PlayerState(
            id: '2',
            name: 'Player 2',
            wonCards: [
              const TichuCard.regular(suit: Suit.pagoda, rank: Rank.king),
            ],
            finishPosition: 3,
            hasFinished: true,
          ),
          PlayerState(
            id: '3',
            name: 'Player 3',
            wonCards: [],
            finishPosition: 4,
            hasFinished: true,
          ),
        ],
      );

      final scores = scoringService.calculateRoundScores(state);

      // Team 0 (players 0,2): 5 + 10 + 10 = 25
      expect(scores['team0'], equals(25));
      // Team 1: 0
      expect(scores['team1'], equals(0));
    });

    test('awards Tichu bonus for finishing first', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            hasCalledTichu: true,
            finishPosition: 1,
            hasFinished: true,
          ),
          PlayerState(
            id: '1',
            name: 'Player 1',
            finishPosition: 2,
            hasFinished: true,
          ),
          PlayerState(
            id: '2',
            name: 'Player 2',
            finishPosition: 3,
            hasFinished: true,
          ),
          PlayerState(
            id: '3',
            name: 'Player 3',
            finishPosition: 4,
            hasFinished: true,
          ),
        ],
      );

      final scores = scoringService.calculateRoundScores(state);

      // Team 0 gets +100 for successful Tichu
      expect(scores['team0'], equals(100));
    });

    test('penalizes failed Tichu', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            hasCalledTichu: true,
            finishPosition: 2, // Failed to finish first
            hasFinished: true,
          ),
          PlayerState(
            id: '1',
            name: 'Player 1',
            finishPosition: 1,
            hasFinished: true,
          ),
          PlayerState(
            id: '2',
            name: 'Player 2',
            finishPosition: 3,
            hasFinished: true,
          ),
          PlayerState(
            id: '3',
            name: 'Player 3',
            finishPosition: 4,
            hasFinished: true,
          ),
        ],
      );

      final scores = scoringService.calculateRoundScores(state);

      // Team 0 gets -100 for failed Tichu
      expect(scores['team0'], equals(-100));
    });

    test('awards double victory bonus (200 points)', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            finishPosition: 1,
            hasFinished: true,
          ),
          PlayerState(
            id: '1',
            name: 'Player 1',
            finishPosition: 3,
            hasFinished: true,
          ),
          PlayerState(
            id: '2',
            name: 'Player 2',
            finishPosition: 2, // Same team as player 0
            hasFinished: true,
          ),
          PlayerState(
            id: '3',
            name: 'Player 3',
            finishPosition: 4,
            hasFinished: true,
          ),
        ],
      );

      final scores = scoringService.calculateRoundScores(state);

      // Team 0 (players 0,2) achieved 1-2 finish
      expect(scores['team0'], equals(200));
      expect(scores['team1'], equals(0));
    });

    test('detects game over when target reached', () {
      final scores = {'team0': 1050, 'team1': 800};
      expect(scoringService.isGameOver(scores), isTrue);
    });

    test('identifies winning team', () {
      final scores = {'team0': 1100, 'team1': 900};
      expect(scoringService.getWinningTeam(scores), equals('team0'));
    });
  });

  group('GameValidator', () {
    test('validates single card play', () {
      final card = const TichuCard.regular(suit: Suit.jade, rank: Rank.ace);
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            hand: [card],
          ),
          PlayerState(id: '1', name: 'Player 1'),
          PlayerState(id: '2', name: 'Player 2'),
          PlayerState(id: '3', name: 'Player 3'),
        ],
        phase: GamePhase.playing,
        currentPlayerIndex: 0,
      );

      final move = TichuMove.play(
        playerId: '0',
        cards: [card],
      );

      final result = GameValidator.validateMove(state, move);
      expect(result.isValid, isTrue);
    });

    test('rejects play when not player\'s turn', () {
      final card = const TichuCard.regular(suit: Suit.jade, rank: Rank.ace);
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(id: '0', name: 'Player 0', hand: [card]),
          PlayerState(id: '1', name: 'Player 1'),
          PlayerState(id: '2', name: 'Player 2'),
          PlayerState(id: '3', name: 'Player 3'),
        ],
        currentPlayerIndex: 1, // Player 1's turn
      );

      final move = TichuMove.play(
        playerId: '0', // Player 0 trying to play
        cards: [card],
      );

      final result = GameValidator.validateMove(state, move);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Not your turn'));
    });

    test('rejects pass when leading trick', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(id: '0', name: 'Player 0'),
          PlayerState(id: '1', name: 'Player 1'),
          PlayerState(id: '2', name: 'Player 2'),
          PlayerState(id: '3', name: 'Player 3'),
        ],
        currentPlayerIndex: 0,
        lastCombination: null, // No previous play
      );

      final move = TichuMove.pass(playerId: '0');

      final result = GameValidator.validateMove(state, move);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Cannot pass when leading'));
    });

    test('validates Tichu call when hand is full', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            hand: List.generate(
              14,
              (i) => TichuCard.regular(
                suit: Suit.jade,
                rank: Rank.values[i % 13],
              ),
            ),
          ),
          PlayerState(id: '1', name: 'Player 1'),
          PlayerState(id: '2', name: 'Player 2'),
          PlayerState(id: '3', name: 'Player 3'),
        ],
      );

      final move = TichuMove.callTichu(playerId: '0');

      final result = GameValidator.validateMove(state, move);
      expect(result.isValid, isTrue);
    });

    test('rejects Tichu call when too late', () {
      final state = TichuGameState(
        id: 'test',
        players: [
          PlayerState(
            id: '0',
            name: 'Player 0',
            hand: List.generate(
              10, // Less than 14 cards
              (i) => TichuCard.regular(
                suit: Suit.jade,
                rank: Rank.values[i],
              ),
            ),
          ),
          PlayerState(id: '1', name: 'Player 1'),
          PlayerState(id: '2', name: 'Player 2'),
          PlayerState(id: '3', name: 'Player 3'),
        ],
      );

      final move = TichuMove.callTichu(playerId: '0');

      final result = GameValidator.validateMove(state, move);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Too late'));
    });
  });

  group('Combination', () {
    test('bomb beats non-bomb', () {
      final bomb = Combination(
        cards: List.generate(
          4,
          (_) => const TichuCard.regular(suit: Suit.jade, rank: Rank.ace),
        ),
        type: CombinationType.bomb,
        highValue: 14,
      );

      final triple = Combination(
        cards: List.generate(
          3,
          (_) => const TichuCard.regular(suit: Suit.sword, rank: Rank.ace),
        ),
        type: CombinationType.triple,
        highValue: 14,
      );

      expect(bomb.beats(triple), isTrue);
      expect(triple.beats(bomb), isFalse);
    });

    test('higher single beats lower single', () {
      final ace = Combination(
        cards: [const TichuCard.regular(suit: Suit.jade, rank: Rank.ace)],
        type: CombinationType.single,
        highValue: 14,
      );

      final king = Combination(
        cards: [const TichuCard.regular(suit: Suit.sword, rank: Rank.king)],
        type: CombinationType.single,
        highValue: 13,
      );

      expect(ace.beats(king), isTrue);
      expect(king.beats(ace), isFalse);
    });
  });
}
