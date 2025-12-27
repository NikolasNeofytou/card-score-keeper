import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'card.dart';

part 'move.g.dart';

enum MoveType {
  play,           // Play cards
  pass,           // Pass turn
  callTichu,      // Call Tichu (100 points)
  callGrandTichu, // Call Grand Tichu (200 points)
  trade,          // Trade cards to partners/opponents
}

/// Represents a player's move
@JsonSerializable()
class TichuMove extends Equatable {
  final String playerId;
  final MoveType type;
  final List<TichuCard> cards;
  final int? wishedRank;  // For Mahjong
  final String? targetPlayerId;  // For trading

  const TichuMove({
    required this.playerId,
    required this.type,
    this.cards = const [],
    this.wishedRank,
    this.targetPlayerId,
  });

  const TichuMove.play({
    required String playerId,
    required List<TichuCard> cards,
    int? wishedRank,
  }) : playerId = playerId,
       type = MoveType.play,
       cards = cards,
       wishedRank = wishedRank,
       targetPlayerId = null;

  const TichuMove.pass({
    required String playerId,
  }) : playerId = playerId,
       type = MoveType.pass,
       cards = const [],
       wishedRank = null,
       targetPlayerId = null;

  const TichuMove.callTichu({
    required String playerId,
  }) : playerId = playerId,
       type = MoveType.callTichu,
       cards = const [],
       wishedRank = null,
       targetPlayerId = null;

  const TichuMove.callGrandTichu({
    required String playerId,
  }) : playerId = playerId,
       type = MoveType.callGrandTichu,
       cards = const [],
       wishedRank = null,
       targetPlayerId = null;

  const TichuMove.trade({
    required String playerId,
    required TichuCard card,
    required String targetPlayerId,
  }) : playerId = playerId,
       type = MoveType.trade,
       cards = const [],
       wishedRank = null,
       targetPlayerId = targetPlayerId;

  @override
  List<Object?> get props => [
        playerId,
        type,
        cards,
        wishedRank,
        targetPlayerId,
      ];

  factory TichuMove.fromJson(Map<String, dynamic> json) =>
      _$TichuMoveFromJson(json);

  Map<String, dynamic> toJson() => _$TichuMoveToJson(this);
}
