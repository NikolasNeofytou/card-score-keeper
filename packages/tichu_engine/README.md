# Tichu Engine

Pure Dart package implementing Tichu card game logic.

## Features

- **Complete Card Model**: 52 regular cards + 4 special cards (Dragon, Phoenix, Dog, Mahjong)
- **Game State Management**: Full game state tracking with players, teams, rounds
- **Move Validation**: Validates all player actions and card combinations
- **Scoring**: Automatic score calculation including:
  - Card points (5s, 10s, Ks)
  - Special card points (Dragon +25, Phoenix -25)
  - Tichu bonuses (+100/-100)
  - Grand Tichu bonuses (+200/-200)
  - Double victory bonus (200 points)
- **Deck Management**: Shuffle, deal, and sort cards
- **Combination Recognition**: Singles, pairs, triples, full houses, straights, bombs
- **JSON Serialization**: All models serialize to/from JSON

## Usage

```dart
import 'package:tichu_engine/tichu_engine.dart';

// Create and shuffle deck
final deck = DeckFactory.shuffleDeck(DeckFactory.createDeck());

// Deal cards
final hands = DeckFactory.dealCards(deck);

// Create game state
final game = TichuGameState(
  id: 'game-1',
  players: [
    PlayerState(id: '0', name: 'Alice', hand: hands[0]!),
    PlayerState(id: '1', name: 'Bob', hand: hands[1]!),
    PlayerState(id: '2', name: 'Charlie', hand: hands[2]!),
    PlayerState(id: '3', name: 'Diana', hand: hands[3]!),
  ],
);

// Validate a move
final move = TichuMove.play(
  playerId: '0',
  cards: [TichuCard.regular(suit: Suit.jade, rank: Rank.ace)],
);

final result = GameValidator.validateMove(game, move);
if (result.isValid) {
  // Apply move to game state
}

// Calculate scores
final scoringService = ScoringService(TichuRuleset.standard());
final scores = scoringService.calculateRoundScores(game);
```

## Card Types

### Regular Cards (52)
- 4 suits: Jade (🟢), Sword (⚔️), Pagoda (🏯), Star (⭐)
- 13 ranks: 2-10, J, Q, K, A

### Special Cards (4)
- **Mahjong (🀄)**: Value 1, always leads, can wish for a rank
- **Dog (🐕)**: Value 0, passes turn to partner
- **Phoenix (🦅)**: Value 1.5, wild card, -25 points
- **Dragon (🐉)**: Highest card, +25 points

## Scoring

- **5**: 5 points
- **10**: 10 points
- **K**: 10 points
- **Dragon**: 25 points
- **Phoenix**: -25 points
- **Tichu**: ±100 points
- **Grand Tichu**: ±200 points
- **Double Victory**: 200 points (1-2 finish by same team)

## Game Phases

1. **Setup**: Deal cards, Grand Tichu calls
2. **Trading**: Players trade 3 cards (1 left, 1 right, 1 across)
3. **Playing**: Main gameplay
4. **Round End**: Score calculation
5. **Game End**: Target score reached (default: 1000)

## Combination Types

- **Single**: 1 card
- **Pair**: 2 cards of same rank
- **Triple**: 3 cards of same rank
- **Full House**: 3 of a kind + pair
- **Straight**: 5+ consecutive cards
- **Straight Pairs**: 2+ consecutive pairs
- **Bomb**: 4 of a kind OR straight flush (beats everything except higher bombs)

## Testing

```bash
dart test
```

## License

MIT
