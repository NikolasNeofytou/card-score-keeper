import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'player_state.dart';
import 'card.dart';
import 'combination.dart';

part 'game_state.g.dart';

enum GamePhase {
  setup,          // Dealing cards, Grand Tichu calls
  trading,        // Players trade 3 cards
  playing,        // Main game play
  roundEnd,       // Round finished, scoring
  gameEnd,        // Target score reached
}

/// Complete state of a Tichu game
@JsonSerializable()
class TichuGameState extends Equatable {
  final String id;
  final List<PlayerState> players;  // Exactly 4 players
  final GamePhase phase;
  final int currentPlayerIndex;
  final List<TichuCard> currentTrick;
  final Combination? lastCombination;
  final int? wishedRank;  // Mahjong wish
  final Map<String, int> teamScores;  // Team 0 (players 0,2) vs Team 1 (players 1,3)
  final int roundNumber;

  const TichuGameState({
    required this.id,
    required this.players,
    this.phase = GamePhase.setup,
    this.currentPlayerIndex = 0,
    this.currentTrick = const [],
    this.lastCombination,
    this.wishedRank,
    this.teamScores = const {'team0': 0, 'team1': 0},
    this.roundNumber = 1,
  });

  TichuGameState copyWith({
    String? id,
    List<PlayerState>? players,
    GamePhase? phase,
    int? currentPlayerIndex,
    List<TichuCard>? currentTrick,
    Combination? lastCombination,
    int? wishedRank,
    Map<String, int>? teamScores,
    int? roundNumber,
  }) {
    return TichuGameState(
      id: id ?? this.id,
      players: players ?? this.players,
      phase: phase ?? this.phase,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentTrick: currentTrick ?? this.currentTrick,
      lastCombination: lastCombination ?? this.lastCombination,
      wishedRank: wishedRank ?? this.wishedRank,
      teamScores: teamScores ?? this.teamScores,
      roundNumber: roundNumber ?? this.roundNumber,
    );
  }

  PlayerState get currentPlayer => players[currentPlayerIndex];

  /// Get team index for a player (0 or 1)
  int teamForPlayer(int playerIndex) => playerIndex % 2;

  @override
  List<Object?> get props => [
        id,
        players,
        phase,
        currentPlayerIndex,
        currentTrick,
        lastCombination,
        wishedRank,
        teamScores,
        roundNumber,
      ];

  factory TichuGameState.fromJson(Map<String, dynamic> json) =>
      _$TichuGameStateFromJson(json);

  Map<String, dynamic> toJson() => _$TichuGameStateToJson(this);
}
