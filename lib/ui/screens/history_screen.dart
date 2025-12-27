// lib/ui/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/round.dart';
import '../../state/game_controller.dart';
import '../../state/game_state.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final game = gameState.currentGame;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Round History')),
        body: const Center(child: Text('No active game')),
      );
    }

    final completedRounds = game.rounds
        .where((r) => r.status == RoundStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Round History'),
        actions: [
          if (completedRounds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Undo Last Round'),
                    content: const Text(
                      'Are you sure you want to undo the last completed round?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Undo'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref
                      .read(gameControllerProvider.notifier)
                      .undoLastCompletedRound();
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
              tooltip: 'Undo Last Round',
            ),
        ],
      ),
      body: completedRounds.isEmpty
          ? const Center(
              child: Text(
                'No completed rounds yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedRounds.length,
              itemBuilder: (context, index) {
                final round = completedRounds[index];
                return Card(
                  child: ExpansionTile(
                    title: Text('Round ${round.index + 1}'),
                    subtitle: Text('${round.cards} cards'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Player',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Pred.',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Actual',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Points',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            ...round.entries.map((entry) {
                              final player = game.players.firstWhere(
                                (p) => p.id == entry.playerId,
                              );
                              final predicted = entry.predictedWins ?? 0;
                              final actual = entry.actualWins ?? 0;
                              final points = computeRoundPoints(
                                predictedWins: predicted,
                                actualWins: actual,
                                bonusExact: game.settings.bonusExact,
                              );
                              final correct = predicted == actual;

                              return TableRow(
                                decoration: correct
                                    ? BoxDecoration(
                                        color: Colors.green.shade50,
                                      )
                                    : null,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(player.name),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(predicted.toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(actual.toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      points.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
