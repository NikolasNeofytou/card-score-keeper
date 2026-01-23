// lib/ui/widgets/animated/player_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/design_tokens.dart';

/// Modern Player Avatar with gaming-inspired design
class PlayerAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double size;
  final bool showBorder;
  final bool isWinner;
  final VoidCallback? onTap;

  const PlayerAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
    this.size = 40,
    this.showBorder = false,
    this.isWinner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorSet = DesignTokens.getPlayerColorSet(colorIndex);
    final initials = _getInitials(name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Modern flat design instead of gradients
        color: colorSet.primary,
        border: showBorder
            ? Border.all(
                color: isDark ? DesignTokens.darkTextPrimary : Colors.white,
                width: size > 50 ? 3 : 2,
              )
            : null,
        // Subtle elevation for depth
        boxShadow: [
          BoxShadow(
            color: colorSet.primary.withOpacity(isDark ? 0.3 : 0.2),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    // Add winner glow effect
    if (isWinner) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DesignTokens.goldPrimary.withOpacity(0.5),
              blurRadius: size * 0.3,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
        child: avatar,
      )
          .animate(
            onComplete: (controller) => controller.repeat(),
          )
          .shimmer(
            duration: 2000.ms,
            color: DesignTokens.goldSecondary.withOpacity(0.3),
          );
    }

    // Add interaction if onTap is provided
    if (onTap != null) {
      avatar = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: avatar,
        ),
      );
    }

    return avatar;
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
