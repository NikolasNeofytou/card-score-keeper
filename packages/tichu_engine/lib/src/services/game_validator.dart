import '../models/game_state.dart';
import '../models/move.dart';
import '../models/combination.dart';
import '../models/card.dart';
import '../models/rank.dart';

/// Validates moves and game state
class GameValidator {
  /// Validate if a move is legal
  static ValidationResult validateMove(TichuGameState state, TichuMove move) {
    // Check if it's the player's turn
    if (move.playerId != state.currentPlayer.id) {
      return ValidationResult.error('Not your turn');
    }

    switch (move.type) {
      case MoveType.play:
        return _validatePlay(state, move);
      case MoveType.pass:
        return _validatePass(state);
      case MoveType.callTichu:
        return _validateTichuCall(state, move);
      case MoveType.callGrandTichu:
        return _validateGrandTichuCall(state, move);
      case MoveType.trade:
        return _validateTrade(state, move);
    }
  }

  static ValidationResult _validatePlay(
    TichuGameState state,
    TichuMove move,
  ) {
    if (move.cards.isEmpty) {
      return ValidationResult.error('No cards played');
    }

    // Check if player has the cards
    final player = state.currentPlayer;
    for (final card in move.cards) {
      if (!player.hand.contains(card)) {
        return ValidationResult.error('Player does not have card: $card');
      }
    }

    // Validate combination
    final combo = _identifyCombination(move.cards);
    if (combo == null) {
      return ValidationResult.error('Invalid card combination');
    }

    // Check if combination beats last play (if any)
    if (state.lastCombination != null) {
      if (!combo.beats(state.lastCombination!)) {
        return ValidationResult.error('Combination does not beat last play');
      }
    }

    // Check Mahjong wish
    if (state.wishedRank != null && !_satisfiesWish(move.cards, state.wishedRank!)) {
      return ValidationResult.error('Must play wished rank if possible');
    }

    return ValidationResult.success();
  }

  static ValidationResult _validatePass(TichuGameState state) {
    // Can't pass if you're starting the trick
    if (state.lastCombination == null) {
      return ValidationResult.error('Cannot pass when leading');
    }

    return ValidationResult.success();
  }

  static ValidationResult _validateTichuCall(
    TichuGameState state,
    TichuMove move,
  ) {
    final player = state.currentPlayer;

    if (player.hasCalledTichu || player.hasCalledGrandTichu) {
      return ValidationResult.error('Tichu already called');
    }

    if (player.hand.length < 14) {
      return ValidationResult.error('Too late to call Tichu');
    }

    return ValidationResult.success();
  }

  static ValidationResult _validateGrandTichuCall(
    TichuGameState state,
    TichuMove move,
  ) {
    final player = state.currentPlayer;

    if (player.hasCalledGrandTichu || player.hasCalledTichu) {
      return ValidationResult.error('Tichu already called');
    }

    if (state.phase != GamePhase.setup) {
      return ValidationResult.error('Too late to call Grand Tichu');
    }

    return ValidationResult.success();
  }

  static ValidationResult _validateTrade(
    TichuGameState state,
    TichuMove move,
  ) {
    if (state.phase != GamePhase.trading) {
      return ValidationResult.error('Not in trading phase');
    }

    if (move.targetPlayerId == null) {
      return ValidationResult.error('No target player specified');
    }

    return ValidationResult.success();
  }

  /// Identify what type of combination the cards form
  static Combination? _identifyCombination(List<TichuCard> cards) {
    if (cards.isEmpty) return null;

    // Single
    if (cards.length == 1) {
      return Combination(
        cards: cards,
        type: CombinationType.single,
        highValue: cards[0].compareValue,
      );
    }

    // Pair
    if (cards.length == 2 && _allSameRank(cards)) {
      return Combination(
        cards: cards,
        type: CombinationType.pair,
        highValue: cards[0].compareValue,
      );
    }

    // Triple
    if (cards.length == 3 && _allSameRank(cards)) {
      return Combination(
        cards: cards,
        type: CombinationType.triple,
        highValue: cards[0].compareValue,
      );
    }

    // Bomb (4 of a kind)
    if (cards.length == 4 && _allSameRank(cards)) {
      return Combination(
        cards: cards,
        type: CombinationType.bomb,
        highValue: cards[0].compareValue,
      );
    }

    // Straight (5+ consecutive cards)
    if (cards.length >= 5 && _isConsecutive(cards)) {
      return Combination(
        cards: cards,
        type: CombinationType.straight,
        highValue: cards.last.compareValue,
      );
    }

    // Full house (3+2)
    if (cards.length == 5) {
      final combo = _checkFullHouse(cards);
      if (combo != null) return combo;
    }

    // Straight flush (bomb)
    if (cards.length >= 5 && _isStraightFlush(cards)) {
      return Combination(
        cards: cards,
        type: CombinationType.bomb,
        highValue: cards.last.compareValue,
      );
    }

    return null;
  }

  static bool _allSameRank(List<TichuCard> cards) {
    if (cards.isEmpty) return false;
    final firstRank = cards[0].rank;
    return cards.every((card) => card.rank == firstRank);
  }

  static bool _isConsecutive(List<TichuCard> cards) {
    final sorted = List<TichuCard>.from(cards)
      ..sort((a, b) => a.compareValue.compareTo(b.compareValue));

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].compareValue != sorted[i - 1].compareValue + 1) {
        return false;
      }
    }
    return true;
  }

  static bool _isStraightFlush(List<TichuCard> cards) {
    if (!_isConsecutive(cards)) return false;
    final firstSuit = cards[0].suit;
    return cards.every((card) => card.suit == firstSuit);
  }

  static Combination? _checkFullHouse(List<TichuCard> cards) {
    final ranks = <Rank, int>{};
    for (final card in cards) {
      if (card.rank == null) return null;
      ranks[card.rank!] = (ranks[card.rank!] ?? 0) + 1;
    }

    if (ranks.length != 2) return null;
    final counts = ranks.values.toList();
    if ((counts[0] == 3 && counts[1] == 2) ||
        (counts[0] == 2 && counts[1] == 3)) {
      final tripleRank = ranks.entries
          .firstWhere((e) => e.value == 3)
          .key;
      return Combination(
        cards: cards,
        type: CombinationType.fullHouse,
        highValue: tripleRank.value,
      );
    }

    return null;
  }

  static bool _satisfiesWish(List<TichuCard> cards, int wishedRank) {
    return cards.any((card) => card.rank?.value == wishedRank);
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => const ValidationResult._(true, null);
  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);
}
