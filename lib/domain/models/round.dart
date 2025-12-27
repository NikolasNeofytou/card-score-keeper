// lib/domain/models/round.dart
enum RoundStatus { empty, predictionsSet, completed }

class RoundEntry {
  final String playerId;
  final int? predictedWins;
  final int? actualWins;

  const RoundEntry({
    required this.playerId,
    this.predictedWins,
    this.actualWins,
  });

  RoundEntry copyWith({int? predictedWins, int? actualWins}) => RoundEntry(
        playerId: playerId,
        predictedWins: predictedWins ?? this.predictedWins,
        actualWins: actualWins ?? this.actualWins,
      );

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'predictedWins': predictedWins,
        'actualWins': actualWins,
      };

  static RoundEntry fromJson(Map<String, dynamic> json) => RoundEntry(
        playerId: json['playerId'] as String,
        predictedWins: json['predictedWins'] as int?,
        actualWins: json['actualWins'] as int?,
      );
}

class GameRound {
  final int index;
  final int cards;
  final RoundStatus status;
  final List<RoundEntry> entries;

  const GameRound({
    required this.index,
    required this.cards,
    required this.status,
    required this.entries,
  });

  GameRound copyWith({RoundStatus? status, List<RoundEntry>? entries}) =>
      GameRound(
        index: index,
        cards: cards,
        status: status ?? this.status,
        entries: entries ?? this.entries,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'cards': cards,
        'status': status.name,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  static GameRound fromJson(Map<String, dynamic> json) => GameRound(
        index: json['index'] as int,
        cards: json['cards'] as int,
        status: RoundStatus.values.firstWhere((s) => s.name == json['status']),
        entries: (json['entries'] as List)
            .map((e) => RoundEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
