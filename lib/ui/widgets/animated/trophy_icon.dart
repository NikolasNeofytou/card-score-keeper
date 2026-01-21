// lib/ui/widgets/animated/trophy_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class TrophyIcon extends StatelessWidget {
  final int rank;
  final double size;

  const TrophyIcon({
    super.key,
    required this.rank,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (rank > 3) {
      return SizedBox(width: size, height: size);
    }

    final color = _getTrophyColor(context, rank);
    final icon = _getTrophyIcon(rank);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.6,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: const Duration(milliseconds: 1500),
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.1, 1.1),
        )
        .then()
        .shimmer(duration: const Duration(milliseconds: 1500));
  }

  Color _getTrophyColor(BuildContext context, int rank) {
    switch (rank) {
      case 1:
        return Theme.of(context).colorScheme.tertiary;
      case 2:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case 3:
        return Theme.of(context).colorScheme.outline;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getTrophyIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events_outlined;
      case 3:
        return Icons.emoji_events_outlined;
      default:
        return Icons.circle;
    }
  }
}
