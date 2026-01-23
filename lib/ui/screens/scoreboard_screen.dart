import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/game.dart' as model;
import '../../state/game_state.dart';
import '../../state/providers.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scoreboard'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No active game'),
        ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(game.name ?? 'Scoreboard'),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Round Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isFinished
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    isFinished
                        ? 'Game Complete!'
                        : 'Round $roundNumber of $totalRounds',
                    style: TextStyle(
                      color: isFinished
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentRound != null && !isFinished) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${currentRound.cards} cards • ${game.state == model.GameState.prediction ? 'Enter predictions' : 'Enter results'}',
                      style: TextStyle(
                        color: isFinished
                            ? Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer
                                .withOpacity(0.7)
                            : Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Simple Leaderboard
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.leaderboard,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFinished ? 'Final Results' : 'Leaderboard',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Leaderboard entries
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: gameState.leaderboard.length,
                        itemBuilder: (context, index) {
                          final entry = gameState.leaderboard[index];
                          final rank = index + 1;
                          final isWinner = rank == 1 && isFinished;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isWinner
                                  ? Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isWinner
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5),
                                width: isWinner ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: rank <= 3
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        color: rank <= 3
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Player name
                                Expanded(
                                  child: Text(
                                    entry.player.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),

                                // Score
                                Text(
                                  '${entry.totalPoints}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: entry.totalPoints >= 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      ),
                                ),

                                if (isWinner)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(Icons.emoji_events,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action button
            if (!isFinished)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: handlePrimaryAction,
                  child: Text(
                    getButtonText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
