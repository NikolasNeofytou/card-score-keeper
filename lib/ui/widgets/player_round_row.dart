// lib/ui/widgets/player_round_row.dart
import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import 'number_stepper.dart';

class PlayerRoundRow extends StatelessWidget {
  final Player player;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final VoidCallback? onMatchPrediction;

  const PlayerRoundRow({
    super.key,
    required this.player,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onMatchPrediction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                player.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              child: NumberStepper(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
            if (onMatchPrediction != null)
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Match prediction',
                onPressed: onMatchPrediction,
              ),
          ],
        ),
      ),
    );
  }
}
