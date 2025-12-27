import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'suit.dart';
import 'rank.dart';
import 'special_card.dart';

part 'card.g.dart';

/// Represents a card in Tichu
@JsonSerializable()
class TichuCard extends Equatable {
  final Suit? suit;
  final Rank? rank;
  final SpecialCard? special;

  const TichuCard({
    this.suit,
    this.rank,
    this.special,
  });

  /// Regular card constructor
  const TichuCard.regular({
    required Suit suit,
    required Rank rank,
  }) : suit = suit,
       rank = rank,
       special = null;

  /// Special card constructor
  const TichuCard.special({
    required SpecialCard special,
  }) : suit = null,
       rank = null,
       special = special;

  bool get isSpecial => special != null;
  bool get isRegular => suit != null && rank != null;

  /// Point value for scoring
  int get pointValue {
    if (special != null) {
      switch (special!) {
        case SpecialCard.dragon:
          return 25;
        case SpecialCard.phoenix:
          return -25;
        case SpecialCard.mahjong:
        case SpecialCard.dog:
          return 0;
      }
    }
    if (rank != null) {
      switch (rank!) {
        case Rank.five:
          return 5;
        case Rank.ten:
        case Rank.king:
          return 10;
        default:
          return 0;
      }
    }
    return 0;
  }

  /// Comparison value for play order
  int get compareValue {
    if (special != null) {
      return special!.sortOrder;
    }
    return rank?.value ?? 0;
  }

  @override
  List<Object?> get props => [suit, rank, special];

  factory TichuCard.fromJson(Map<String, dynamic> json) =>
      _$TichuCardFromJson(json);

  Map<String, dynamic> toJson() => _$TichuCardToJson(this);

  @override
  String toString() {
    if (special != null) {
      return special!.symbol;
    }
    return '${rank!.display}${suit!.symbol}';
  }
}
