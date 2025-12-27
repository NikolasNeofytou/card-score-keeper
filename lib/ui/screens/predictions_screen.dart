// lib/ui/screens/predictions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../state/providers.dart';
import '../widgets/player_round_row.dart';
import '../theme/app_colors.dart';
import '../widgets/animated/player_avatar.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({super.key});

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen> {
  final Map<String, int> _predictions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(gameControllerProvider);
      final game = gameState.currentGame;
      if (game != null) {
        setState(() {
          for (final player in game.players) {
            _predictions[player.id] = 0;
          }
        });
      }
    });
  }

  Future<void> _savePredictions() async {
    try {
      // Record state before saving for undo
      final currentState = ref.read(gameControllerProvider);
      ref.read(undoControllerProvider.notifier).recordState(currentState);
      
      await ref.read(gameControllerProvider.notifier).savePredictions(_predictions);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save predictions: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        appBar: AppBar(title: const Text('Predictions')),
        body: const Center(child: Text('No active round')),
      );
    }

    final cardsThisRound = currentRound.cards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Predictions'),
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.activeBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Round ${game.currentRoundIndex + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$cardsThisRound cards • Predict how many tricks each player will win',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: game.players.length,
                  itemBuilder: (context, index) {
                    final player = game.players[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
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
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            PlayerRoundRow(
                              player: player,
                              value: _predictions[player.id] ?? 0,
                              min: 0,
                              max: cardsThisRound,
                              onChanged: (value) {
                                setState(() {
                                  _predictions[player.id] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: -0.2, end: 0);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _savePredictions,
                  icon: Icon(Icons.check_circle, size: 20),
                  label: Text('Save Predictions'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
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
