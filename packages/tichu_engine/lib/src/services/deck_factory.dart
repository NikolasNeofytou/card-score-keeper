import '../models/card.dart';
import '../models/suit.dart';
import '../models/rank.dart';
import '../models/special_card.dart';

/// Factory for creating Tichu decks
class DeckFactory {
  /// Creates a standard Tichu deck (56 cards)
  /// - 52 regular cards (4 suits × 13 ranks)
  /// - 4 special cards (Mahjong, Dog, Phoenix, Dragon)
  static List<TichuCard> createDeck() {
    final cards = <TichuCard>[];

    // Add regular cards (52)
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        cards.add(TichuCard.regular(suit: suit, rank: rank));
      }
    }

    // Add special cards (4)
    for (final special in SpecialCard.values) {
      cards.add(TichuCard.special(special: special));
    }

    return cards;
  }

  /// Shuffles a deck
  static List<TichuCard> shuffleDeck(List<TichuCard> deck) {
    final shuffled = List<TichuCard>.from(deck);
    shuffled.shuffle();
    return shuffled;
  }

  /// Deals cards to 4 players (14 cards each)
  static Map<int, List<TichuCard>> dealCards(List<TichuCard> deck) {
    if (deck.length != 56) {
      throw ArgumentError('Deck must have exactly 56 cards');
    }

    final hands = <int, List<TichuCard>>{};
    for (int i = 0; i < 4; i++) {
      hands[i] = [];
    }

    // Deal 14 cards to each player
    for (int i = 0; i < deck.length; i++) {
      hands[i % 4]!.add(deck[i]);
    }

    return hands;
  }

  /// Sorts a hand by suit and rank
  static List<TichuCard> sortHand(List<TichuCard> hand) {
    final sorted = List<TichuCard>.from(hand);
    sorted.sort((a, b) {
      // Special cards first, sorted by their order
      if (a.isSpecial && b.isSpecial) {
        return a.special!.sortOrder.compareTo(b.special!.sortOrder);
      }
      if (a.isSpecial) return -1;
      if (b.isSpecial) return 1;

      // Then by suit
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }

      // Then by rank
      return a.rank!.value.compareTo(b.rank!.value);
    });
    return sorted;
  }
}
