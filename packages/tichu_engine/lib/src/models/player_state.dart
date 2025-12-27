import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'card.dart';

part 'player_state.g.dart';

/// State of a single player in a Tichu game
@JsonSerializable()
class PlayerState extends Equatable {
  final String id;
  final String name;
  final List<TichuCard> hand;
  final List<TichuCard> wonCards;
  final bool hasCalledTichu;
  final bool hasCalledGrandTichu;
  final bool hasFinished;
  final int finishPosition;  // 0 = not finished, 1-4 = finish order

  const PlayerState({
    required this.id,
    required this.name,
    this.hand = const [],
    this.wonCards = const [],
    this.hasCalledTichu = false,
    this.hasCalledGrandTichu = false,
    this.hasFinished = false,
    this.finishPosition = 0,
  });

  PlayerState copyWith({
    String? id,
    String? name,
    List<TichuCard>? hand,
    List<TichuCard>? wonCards,
    bool? hasCalledTichu,
    bool? hasCalledGrandTichu,
    bool? hasFinished,
    int? finishPosition,
  }) {
    return PlayerState(
      id: id ?? this.id,
      name: name ?? this.name,
      hand: hand ?? this.hand,
      wonCards: wonCards ?? this.wonCards,
      hasCalledTichu: hasCalledTichu ?? this.hasCalledTichu,
      hasCalledGrandTichu: hasCalledGrandTichu ?? this.hasCalledGrandTichu,
      hasFinished: hasFinished ?? this.hasFinished,
      finishPosition: finishPosition ?? this.finishPosition,
    );
  }

  int get handSize => hand.length;
  int get pointsInHand => hand.fold(0, (sum, card) => sum + card.pointValue);
  int get pointsWon => wonCards.fold(0, (sum, card) => sum + card.pointValue);

  @override
  List<Object?> get props => [
        id,
        name,
        hand,
        wonCards,
        hasCalledTichu,
        hasCalledGrandTichu,
        hasFinished,
        finishPosition,
      ];

  factory PlayerState.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStateToJson(this);
}
