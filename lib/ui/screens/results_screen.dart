// lib/ui/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/logic/scoring.dart';
import '../../state/providers.dart';
import '../widgets/player_round_row.dart';
import '../widgets/animated/player_avatar.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final Map<String, int> _actualWins = {};
  String? _validationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(gameControllerProvider);
      final game = gameState.currentGame;
      if (game != null) {
        setState(() {
          for (final player in game.players) {
            _actualWins[player.id] = 0;
          }
        });
      }
    });
  }

  void _validate() {
    final error =
        ref.read(gameControllerProvider.notifier).validateResults(_actualWins);
    setState(() {
      _validationError = error;
    });
  }

  Future<void> _saveResults() async {
    _validate();
    if (_validationError == null) {
      // Record state before saving for undo
      final currentGame = ref.read(gameControllerProvider).currentGame;
      if (currentGame != null) {
        ref.read(undoControllerProvider.notifier).recordState(currentGame);
      }

      await ref.read(gameControllerProvider.notifier).saveResults(_actualWins);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final game = gameState.currentGame;
    final currentRound = gameState.currentRound;

    if (game == null || currentRound == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No active round')),
      );
    }

    final cardsThisRound = currentRound.cards;
    final totalWins = _actualWins.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Results'),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: totalWins == cardsThisRound
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: totalWins == cardsThisRound
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            totalWins == cardsThisRound
                                ? Icons.check_circle
                                : Icons.casino,
                            color: totalWins == cardsThisRound
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Round ${game.currentRoundIndex + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$cardsThisRound cards • Total wins: $totalWins / $cardsThisRound',
                        style: TextStyle(
                          fontSize: 14,
                          color: totalWins == cardsThisRound
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: totalWins == cardsThisRound
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(),
              if (_validationError != null) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().shake(),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: game.players.length,
                  itemBuilder: (context, index) {
                    final player = game.players[index];
                    final entry = currentRound.entries.firstWhere(
                      (e) => e.playerId == player.id,
                    );
                    final predictedWins = entry.predictedWins ?? 0;
                    final actualWins = _actualWins[player.id] ?? 0;
                    final correct = actualWins == predictedWins;
                    final points = computeRoundPoints(
                      predictedWins: predictedWins,
                      actualWins: actualWins,
                      bonusExact: game.settings.bonusExact,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: correct
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surface,
                      child: Container(
                        decoration: correct
                            ? BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  PlayerAvatar(
                                    name: player.name,
                                    colorIndex: index,
                                    size: 40,
                                    showBorder: correct,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        Text(
                                          'Predicted: $predictedWins',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (correct)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            '+${game.settings.bonusExact}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              PlayerRoundRow(
                                player: player,
                                value: actualWins,
                                min: 0,
                                max: cardsThisRound,
                                onChanged: (value) {
                                  setState(() {
                                    _actualWins[player.id] = value;
                                    _validate();
                                  });
                                },
                                onMatchPrediction: () {
                                  setState(() {
                                    _actualWins[player.id] = predictedWins;
                                    _validate();
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: correct
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.2)
                                          : Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      correct ? '✓ Correct!' : '✗ Incorrect',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: correct
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Points: $points',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                        .slideX(begin: -0.2, end: 0);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: _validationError == null
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer
                          ],
                        )
                      : LinearGradient(
                          colors: [Colors.grey, Colors.grey.shade700]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _validationError == null
                      ? [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _validationError == null ? _saveResults : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Save Results',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
