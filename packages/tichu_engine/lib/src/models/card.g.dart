// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TichuCard _$TichuCardFromJson(Map<String, dynamic> json) => TichuCard(
  suit: $enumDecodeNullable(_$SuitEnumMap, json['suit']),
  rank: $enumDecodeNullable(_$RankEnumMap, json['rank']),
  special: $enumDecodeNullable(_$SpecialCardEnumMap, json['special']),
);

Map<String, dynamic> _$TichuCardToJson(TichuCard instance) => <String, dynamic>{
  'suit': _$SuitEnumMap[instance.suit],
  'rank': _$RankEnumMap[instance.rank],
  'special': _$SpecialCardEnumMap[instance.special],
};

const _$SuitEnumMap = {
  Suit.jade: 'jade',
  Suit.sword: 'sword',
  Suit.pagoda: 'pagoda',
  Suit.star: 'star',
};

const _$RankEnumMap = {
  Rank.two: 'two',
  Rank.three: 'three',
  Rank.four: 'four',
  Rank.five: 'five',
  Rank.six: 'six',
  Rank.seven: 'seven',
  Rank.eight: 'eight',
  Rank.nine: 'nine',
  Rank.ten: 'ten',
  Rank.jack: 'jack',
  Rank.queen: 'queen',
  Rank.king: 'king',
  Rank.ace: 'ace',
};

const _$SpecialCardEnumMap = {
  SpecialCard.mahjong: 'mahjong',
  SpecialCard.dog: 'dog',
  SpecialCard.phoenix: 'phoenix',
  SpecialCard.dragon: 'dragon',
};
