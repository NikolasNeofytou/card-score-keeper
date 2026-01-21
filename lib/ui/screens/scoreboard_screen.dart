// lib/ui/screens/scoreboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/game.dart' as model;
import '../../state/game_state.dart';
import '../../state/providers.dart';
import '../widgets/animated/trophy_icon.dart';
import '../widgets/animated/player_avatar.dart';
import '../widgets/animated/animated_score.dart';
import '../widgets/animated/confetti_celebration.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  bool _isClutchSituation(model.Game game, List<LeaderboardEntry> leaderboard) {
    if (leaderboard.length < 2) return false;

    final topScore = leaderboard[0].totalPoints;
    final secondScore = leaderboard[1].totalPoints;
    final scoreDifference = topScore - secondScore;

    // Clutch if difference is small or if we're in the last few rounds
    final isCloseScore = scoreDifference <= 30;
    final isLateGame = game.currentRoundIndex >= (game.rounds.length * 0.7);
    final hasNegativeScores = leaderboard.any((entry) => entry.totalPoints < 0);

    return isCloseScore ||
        (isLateGame && scoreDifference <= 50) ||
        hasNegativeScores;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scoreboard')),
        body: const Center(child: Text('No active game')),
      );
    }

    final isFinished = game.state == model.GameState.finished;
    final currentRound = gameState.currentRound;
    final roundNumber = game.currentRoundIndex + 1;
    final totalRounds = game.rounds.length;

    String getButtonText() {
      if (isFinished) return 'Game Finished';
      if (game.state == model.GameState.prediction) {
        return 'Start Round $roundNumber';
      } else {
        return 'End Round $roundNumber';
      }
    }

    void handlePrimaryAction() {
      if (isFinished) return;

      if (game.state == model.GameState.prediction) {
        context.push('/predictions');
      } else {
        context.push('/results');
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(game.name ?? 'Scoreboard'),
          actions: [
            // Undo button
            Consumer(
              builder: (context, ref, _) {
                final undoState = ref.watch(undoControllerProvider);
                return IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: undoState.canUndo
                      ? () {
                          final previousState =
                              ref.read(undoControllerProvider.notifier).undo();
                          if (previousState != null) {
                            ref
                                .read(gameControllerProvider.notifier)
                                .restoreState(previousState);
                          }
                        }
                      : null,
                  tooltip: 'Undo',
                );
              },
            ),
            // Redo button
            Consumer(
              builder: (context, ref, _) {
                final undoState = ref.watch(undoControllerProvider);
                return IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: undoState.canRedo
                      ? () {
                          final nextState =
                              ref.read(undoControllerProvider.notifier).redo();
                          if (nextState != null) {
                            ref
                                .read(gameControllerProvider.notifier)
                                .restoreState(nextState);
                          }
                        }
                      : null,
                  tooltip: 'Redo',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => context.push('/history'),
              tooltip: 'Round History',
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new',
                  child: Text('New Game'),
                ),
              ],
              onSelected: (value) {
                if (value == 'new') {
                  context.go('/create');
                }
              },
            ),
          ],
        ),
        body: ConfettiCelebration(
          shouldCelebrate: isFinished,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainer,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Round Info Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isFinished
                            ? [
                                Theme.of(context).colorScheme.tertiary,
                                Theme.of(context).colorScheme.tertiaryContainer
                              ]
                            : [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isFinished)
                                Icon(
                                  Icons.emoji_events,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 24,
                                ),
                              if (isFinished) const SizedBox(width: 8),
                              Text(
                                isFinished
                                    ? 'Game Complete!'
                                    : 'Round $roundNumber of $totalRounds',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isFinished
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if (currentRound != null && !isFinished) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${currentRound.cards} cards • ${game.state == model.GameState.prediction ? 'Enter predictions' : 'Enter results'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).scale(),

                  const SizedBox(height: 24),

                  // Clutch Indicator
                  if (_isClutchSituation(game, gameState.leaderboard) &&
                      !isFinished)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => context.push('/clutch'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CLUTCH TIME!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                      ),
                                      Text(
                                        'This game is getting intense!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.02, 1.02),
                          duration: 1000.ms,
                        ),

                  // Leaderboard
                  Expanded(
                    child: _buildLeaderboard(gameState.leaderboard),
                  ),

                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isFinished ? null : handlePrimaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        disabledBackgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        disabledForegroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(getButtonText()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildLeaderboard(List<LeaderboardEntry> entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final rank = index + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: rank == 1
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: rank == 1
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.outline,
              width: rank == 1 ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Trophy or Rank
                SizedBox(
                  width: 40,
                  child: rank <= 3
                      ? TrophyIcon(rank: rank, size: 36)
                      : Center(
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                // Player Avatar
                PlayerAvatar(
                  name: entry.player.name,
                  colorIndex: index,
                  size: 48,
                  showBorder: rank == 1,
                ),

                const SizedBox(width: 16),

                // Player Name
                Expanded(
                  child: Text(
                    entry.player.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                // Score
                AnimatedScore(
                  score: entry.totalPoints,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: rank == 1
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (50 * index).ms)
            .slideX(begin: 0.2, end: 0);
      },
    );
  }
}
