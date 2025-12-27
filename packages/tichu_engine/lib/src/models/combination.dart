import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'card.dart';

part 'combination.g.dart';

/// Types of valid card combinations in Tichu
enum CombinationType {
  single,
  pair,
  triple,
  fullHouse,      // 3 + 2
  straight,       // 5+ consecutive cards
  straightPairs,  // 2+ consecutive pairs
  bomb,           // 4 of a kind or straight flush
}

/// Represents a valid combination of cards
@JsonSerializable()
class Combination extends Equatable {
  final List<TichuCard> cards;
  final CombinationType type;
  final int highValue;

  const Combination({
    required this.cards,
    required this.type,
    required this.highValue,
  });

  bool get isBomb => type == CombinationType.bomb;

  /// Check if this combination beats another
  bool beats(Combination other) {
    // Bombs beat everything except higher bombs
    if (isBomb && !other.isBomb) return true;
    if (!isBomb && other.isBomb) return false;

    // Same type: compare high values
    if (type == other.type && cards.length == other.cards.length) {
      return highValue > other.highValue;
    }

    return false;
  }

  @override
  List<Object?> get props => [cards, type, highValue];

  factory Combination.fromJson(Map<String, dynamic> json) =>
      _$CombinationFromJson(json);

  Map<String, dynamic> toJson() => _$CombinationToJson(this);
}
