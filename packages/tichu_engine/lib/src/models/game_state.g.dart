// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TichuGameState _$TichuGameStateFromJson(
  Map<String, dynamic> json,
) => TichuGameState(
  id: json['id'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => PlayerState.fromJson(e as Map<String, dynamic>))
      .toList(),
  phase:
      $enumDecodeNullable(_$GamePhaseEnumMap, json['phase']) ?? GamePhase.setup,
  currentPlayerIndex: (json['currentPlayerIndex'] as num?)?.toInt() ?? 0,
  currentTrick:
      (json['currentTrick'] as List<dynamic>?)
          ?.map((e) => TichuCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastCombination: json['lastCombination'] == null
      ? null
      : Combination.fromJson(json['lastCombination'] as Map<String, dynamic>),
  wishedRank: (json['wishedRank'] as num?)?.toInt(),
  teamScores:
      (json['teamScores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {'team0': 0, 'team1': 0},
  roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$TichuGameStateToJson(TichuGameState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'players': instance.players,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'currentPlayerIndex': instance.currentPlayerIndex,
      'currentTrick': instance.currentTrick,
      'lastCombination': instance.lastCombination,
      'wishedRank': instance.wishedRank,
      'teamScores': instance.teamScores,
      'roundNumber': instance.roundNumber,
    };

const _$GamePhaseEnumMap = {
  GamePhase.setup: 'setup',
  GamePhase.trading: 'trading',
  GamePhase.playing: 'playing',
  GamePhase.roundEnd: 'roundEnd',
  GamePhase.gameEnd: 'gameEnd',
};
