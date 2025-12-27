// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Combination _$CombinationFromJson(Map<String, dynamic> json) => Combination(
  cards: (json['cards'] as List<dynamic>)
      .map((e) => TichuCard.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: $enumDecode(_$CombinationTypeEnumMap, json['type']),
  highValue: (json['highValue'] as num).toInt(),
);

Map<String, dynamic> _$CombinationToJson(Combination instance) =>
    <String, dynamic>{
      'cards': instance.cards,
      'type': _$CombinationTypeEnumMap[instance.type]!,
      'highValue': instance.highValue,
    };

const _$CombinationTypeEnumMap = {
  CombinationType.single: 'single',
  CombinationType.pair: 'pair',
  CombinationType.triple: 'triple',
  CombinationType.fullHouse: 'fullHouse',
  CombinationType.straight: 'straight',
  CombinationType.straightPairs: 'straightPairs',
  CombinationType.bomb: 'bomb',
};
