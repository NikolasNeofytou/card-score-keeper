// lib/ui/widgets/leaderboard_table.dart
import 'package:flutter/material.dart';
import '../../state/game_state.dart';

class LeaderboardTable extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              border:
                  TableBorder.all(color: Theme.of(context).colorScheme.outline),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Rank',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Player',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Points',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...entries.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final leaderboardEntry = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(rank.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(leaderboardEntry.player.name),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          leaderboardEntry.totalPoints.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
