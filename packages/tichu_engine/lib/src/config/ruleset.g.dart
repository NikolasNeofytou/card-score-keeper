// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ruleset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TichuRuleset _$TichuRulesetFromJson(Map<String, dynamic> json) => TichuRuleset(
  targetScore: (json['targetScore'] as num?)?.toInt() ?? 1000,
  allowDoubleVictory: json['allowDoubleVictory'] as bool? ?? true,
  tichuPoints: (json['tichuPoints'] as num?)?.toInt() ?? 100,
  grandTichuPoints: (json['grandTichuPoints'] as num?)?.toInt() ?? 200,
  doubleVictoryPoints: (json['doubleVictoryPoints'] as num?)?.toInt() ?? 200,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 4,
);

Map<String, dynamic> _$TichuRulesetToJson(TichuRuleset instance) =>
    <String, dynamic>{
      'targetScore': instance.targetScore,
      'allowDoubleVictory': instance.allowDoubleVictory,
      'tichuPoints': instance.tichuPoints,
      'grandTichuPoints': instance.grandTichuPoints,
      'doubleVictoryPoints': instance.doubleVictoryPoints,
      'maxPlayers': instance.maxPlayers,
    };
