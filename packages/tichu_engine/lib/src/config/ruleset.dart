import 'package:json_annotation/json_annotation.dart';

part 'ruleset.g.dart';

/// Tichu game rules configuration
@JsonSerializable()
class TichuRuleset {
  /// Target score to win the game
  final int targetScore;

  /// Whether double victory (1-2 finish) is enabled
  final bool allowDoubleVictory;

  /// Points for Tichu call success
  final int tichuPoints;

  /// Points for Grand Tichu call success
  final int grandTichuPoints;

  /// Points for double victory bonus
  final int doubleVictoryPoints;

  /// Maximum players (always 4 in standard Tichu)
  final int maxPlayers;

  const TichuRuleset({
    this.targetScore = 1000,
    this.allowDoubleVictory = true,
    this.tichuPoints = 100,
    this.grandTichuPoints = 200,
    this.doubleVictoryPoints = 200,
    this.maxPlayers = 4,
  });

  factory TichuRuleset.standard() => const TichuRuleset();

  factory TichuRuleset.quick() => const TichuRuleset(
        targetScore = 500,
      );

  factory TichuRuleset.noDoubleVictory() => const TichuRuleset(
        allowDoubleVictory: false,
      );

  factory TichuRuleset.fromJson(Map<String, dynamic> json) =>
      _$TichuRulesetFromJson(json);

  Map<String, dynamic> toJson() => _$TichuRulesetToJson(this);
}
