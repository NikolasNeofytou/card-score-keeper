// lib/ui/widgets/animated/player_avatar.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PlayerAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double size;
  final bool showBorder;

  const PlayerAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getPlayerColor(colorIndex);
    final initials = _getInitials(name);

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
        border: showBorder
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}
