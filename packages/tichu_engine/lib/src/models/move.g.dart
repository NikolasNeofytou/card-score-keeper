// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TichuMove _$TichuMoveFromJson(Map<String, dynamic> json) => TichuMove(
  playerId: json['playerId'] as String,
  type: $enumDecode(_$MoveTypeEnumMap, json['type']),
  cards:
      (json['cards'] as List<dynamic>?)
          ?.map((e) => TichuCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  wishedRank: (json['wishedRank'] as num?)?.toInt(),
  targetPlayerId: json['targetPlayerId'] as String?,
);

Map<String, dynamic> _$TichuMoveToJson(TichuMove instance) => <String, dynamic>{
  'playerId': instance.playerId,
  'type': _$MoveTypeEnumMap[instance.type]!,
  'cards': instance.cards,
  'wishedRank': instance.wishedRank,
  'targetPlayerId': instance.targetPlayerId,
};

const _$MoveTypeEnumMap = {
  MoveType.play: 'play',
  MoveType.pass: 'pass',
  MoveType.callTichu: 'callTichu',
  MoveType.callGrandTichu: 'callGrandTichu',
  MoveType.trade: 'trade',
};
