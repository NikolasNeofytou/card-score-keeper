// lib/ui/screens/clutch_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/game.dart' as model;
import '../../domain/models/round.dart';
import '../../state/providers.dart';
import '../../state/game_state.dart';
import '../widgets/animated/player_avatar.dart';

class ClutchScreen extends ConsumerWidget {
  const ClutchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clutch Moments')),
        body: const Center(child: Text('No active game')),
      );
    }

    final clutchData = _analyzeClutchSituation(gameState);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: clutchData.isClutch
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                clutchData.isClutch ? '🔥 CLUTCH TIME' : 'Game Analysis',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: clutchData.isClutch
                        ? [
                            Theme.of(context).colorScheme.error,
                            Theme.of(context).colorScheme.errorContainer,
                          ]
                        : [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                  ),
                ),
                child: clutchData.isClutch
                    ? Center(
                        child: Icon(
                          Icons.whatshot,
                          size: 80,
                          color: Theme.of(context).colorScheme.onError,
                        ).animate().scale(
                              duration: 1.seconds,
                              curve: Curves.elasticOut,
                            ),
                      )
                    : null,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (clutchData.isClutch) ...[
                  _buildClutchAlert(context, clutchData),
                  const SizedBox(height: 24),
                ],
                _buildGameStatus(context, game, gameState),
                const SizedBox(height: 24),
                _buildPlayerStandings(context, gameState, clutchData),
                const SizedBox(height: 24),
                _buildClutchMetrics(context, clutchData),
                const SizedBox(height: 24),
                _buildTensionIndicators(context, clutchData),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClutchAlert(BuildContext context, ClutchAnalysis clutchData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'CLUTCH SITUATION DETECTED!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            clutchData.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.5, end: 0, duration: 500.ms)
        .then()
        .shimmer(duration: 2.seconds);
  }

  Widget _buildGameStatus(
      BuildContext context, model.Game game, GameState gameState) {
    final totalRounds = game.rounds.length;
    final currentRound = game.currentRoundIndex + 1;
    final completedRounds =
        game.rounds.where((r) => r.status == RoundStatus.completed).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusItem(
                    context, 'Round', '$currentRound / $totalRounds'),
                _buildStatusItem(context, 'Completed', '$completedRounds'),
                _buildStatusItem(context, 'Players', '${game.players.length}'),
                _buildStatusItem(
                    context, 'Peak Cards', '${game.settings.peakCards}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildPlayerStandings(
      BuildContext context, GameState gameState, ClutchAnalysis clutchData) {
    final leaderboard = gameState.leaderboard;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Standings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...leaderboard.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final player = entry.value;
              final isInClutchGroup =
                  clutchData.clutchPlayers.contains(player.player.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isInClutchGroup
                      ? Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withOpacity(0.3)
                      : Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: isInClutchGroup
                      ? Border.all(
                          color: Theme.of(context).colorScheme.error, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rank <= 3
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PlayerAvatar(
                      name: player.player.name,
                      colorIndex: rank - 1,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.player.name,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          if (isInClutchGroup)
                            Text(
                              '🔥 IN THE CLUTCH',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${player.totalPoints}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isInClutchGroup
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          'points',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildClutchMetrics(BuildContext context, ClutchAnalysis clutchData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tension Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Point Spread',
                    '${clutchData.pointSpread}',
                    clutchData.pointSpread <= 5 ? Colors.red : Colors.orange,
                    Icons.trending_flat,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Tension Level',
                    '${(clutchData.tensionLevel * 100).round()}%',
                    clutchData.tensionLevel > 0.7 ? Colors.red : Colors.orange,
                    Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Rounds Left',
                    '${clutchData.roundsRemaining}',
                    clutchData.roundsRemaining <= 3 ? Colors.red : Colors.blue,
                    Icons.timer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Tied Players',
                    '${clutchData.tiedPlayersCount}',
                    clutchData.tiedPlayersCount > 1 ? Colors.red : Colors.green,
                    Icons.people,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTensionIndicators(
      BuildContext context, ClutchAnalysis clutchData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pressure Indicators',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...clutchData.indicators
                .map((indicator) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            indicator.isActive
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: indicator.isActive
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              indicator.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: indicator.isActive
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: indicator.isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/scoreboard'),
            icon: const Icon(Icons.leaderboard),
            label: const Text('View Full Scoreboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history),
            label: const Text('Game History'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  ClutchAnalysis _analyzeClutchSituation(GameState gameState) {
    final game = gameState.currentGame!;
    final leaderboard = gameState.leaderboard;

    if (leaderboard.isEmpty) {
      return ClutchAnalysis.notClutch();
    }

    // Calculate metrics
    final scores = leaderboard.map((entry) => entry.totalPoints).toList();
    scores.sort((a, b) => b.compareTo(a));

    if (scores.isEmpty) {
      return ClutchAnalysis(
        isClutch: false,
        clutchPlayers: [],
        pointSpread: 0,
        description: 'No scores available',
        tensionLevel: 0.0,
        roundsRemaining: 0,
        tiedPlayersCount: 0,
        indicators: [],
      );
    }

    final pointSpread = scores.first - scores.last;
    final roundsRemaining = game.rounds.length - game.currentRoundIndex - 1;
    final isNearEnd = roundsRemaining <= 3;

    // Find tied players (within 5 points)
    final topScore = scores.first;
    final clutchPlayers = leaderboard
        .where((entry) => topScore - entry.totalPoints <= 5)
        .map((entry) => entry.player.id)
        .toList();

    // Count exact ties
    final tiedPlayersCount =
        leaderboard.where((entry) => entry.totalPoints == topScore).length;

    // Calculate tension level
    double tensionLevel = 0.0;
    if (pointSpread <= 5) tensionLevel += 0.4;
    if (roundsRemaining <= 3) tensionLevel += 0.3;
    if (clutchPlayers.length >= 2) tensionLevel += 0.2;
    if (tiedPlayersCount > 1) tensionLevel += 0.1;

    // Build indicators
    final indicators = <PressureIndicator>[
      PressureIndicator('Close scores (≤5 point spread)', pointSpread <= 5),
      PressureIndicator('Final rounds approaching', roundsRemaining <= 3),
      PressureIndicator(
          'Multiple players in contention', clutchPlayers.length >= 2),
      PressureIndicator('Tied for first place', tiedPlayersCount > 1),
      PressureIndicator('Late game pressure', isNearEnd && pointSpread <= 10),
    ];

    final isClutch = tensionLevel >= 0.5;
    String description = '';
    if (isClutch) {
      if (tiedPlayersCount > 1) {
        description = 'Multiple players tied for the lead!';
      } else if (pointSpread <= 3 && isNearEnd) {
        description = 'Extremely close game with few rounds remaining!';
      } else if (clutchPlayers.length >= 3) {
        description =
            '${clutchPlayers.length} players within striking distance!';
      } else {
        description = 'High tension situation detected!';
      }
    }

    return ClutchAnalysis(
      isClutch: isClutch,
      description: description,
      tensionLevel: tensionLevel,
      pointSpread: pointSpread,
      roundsRemaining: roundsRemaining,
      clutchPlayers: clutchPlayers,
      tiedPlayersCount: tiedPlayersCount,
      indicators: indicators,
    );
  }
}

class ClutchAnalysis {
  final bool isClutch;
  final String description;
  final double tensionLevel;
  final int pointSpread;
  final int roundsRemaining;
  final List<String> clutchPlayers;
  final int tiedPlayersCount;
  final List<PressureIndicator> indicators;

  ClutchAnalysis({
    required this.isClutch,
    required this.description,
    required this.tensionLevel,
    required this.pointSpread,
    required this.roundsRemaining,
    required this.clutchPlayers,
    required this.tiedPlayersCount,
    required this.indicators,
  });

  factory ClutchAnalysis.notClutch() => ClutchAnalysis(
        isClutch: false,
        description: 'Game is progressing normally',
        tensionLevel: 0.0,
        pointSpread: 0,
        roundsRemaining: 0,
        clutchPlayers: [],
        tiedPlayersCount: 0,
        indicators: [],
      );
}

class PressureIndicator {
  final String description;
  final bool isActive;

  PressureIndicator(this.description, this.isActive);
}
