// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerState _$PlayerStateFromJson(Map<String, dynamic> json) => PlayerState(
  id: json['id'] as String,
  name: json['name'] as String,
  hand:
      (json['hand'] as List<dynamic>?)
          ?.map((e) => TichuCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  wonCards:
      (json['wonCards'] as List<dynamic>?)
          ?.map((e) => TichuCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  hasCalledTichu: json['hasCalledTichu'] as bool? ?? false,
  hasCalledGrandTichu: json['hasCalledGrandTichu'] as bool? ?? false,
  hasFinished: json['hasFinished'] as bool? ?? false,
  finishPosition: (json['finishPosition'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerStateToJson(PlayerState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hand': instance.hand,
      'wonCards': instance.wonCards,
      'hasCalledTichu': instance.hasCalledTichu,
      'hasCalledGrandTichu': instance.hasCalledGrandTichu,
      'hasFinished': instance.hasFinished,
      'finishPosition': instance.finishPosition,
    };
