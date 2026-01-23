// lib/ui/widgets/clutch_notification_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_tokens.dart';

/// Modern clutch situation notification banner
/// Replaces the old red "CLUTCH TIME!" with elegant design
class ClutchNotificationBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;
  final bool isVisible;

  const ClutchNotificationBanner({
    super.key,
    required this.message,
    this.onTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(DesignTokens.space16),
      child: Material(
        elevation: DesignTokens.elevationMedium,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        shadowColor: DesignTokens.primaryOrange.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space20,
              vertical: DesignTokens.space16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primaryOrange,
                  DesignTokens.goldenYellow,
                ],
              ),
            ),
            child: Row(
              children: [
                // Flame icon for excitement
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 24,
                )
                    .animate(
                      onComplete: (controller) => controller.repeat(),
                    )
                    .scale(
                      duration: 1000.ms,
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(width: DesignTokens.space12),

                // Message text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CLUTCH MOMENT!',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: DesignTokens.space12),

                // Arrow icon for interactivity
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .slideX(
            begin: 1.0,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(
            duration: 300.ms,
          ),
    );
  }
}

/// Different styles of clutch notifications for variety
class ClutchNotificationStyle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const ClutchNotificationStyle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  });

  // Factory constructors for different clutch scenarios
  factory ClutchNotificationStyle.intense({
    required String message,
    VoidCallback? onTap,
  }) {
    return ClutchNotificationStyle(
      title: 'INTENSE MOMENT!',
      subtitle: message,
      icon: Icons.bolt_rounded,
      gradientColors: [
        DesignTokens.crimsonRed,
        DesignTokens.primaryOrange,
      ],
      onTap: onTap,
    );
  }

  factory ClutchNotificationStyle.closeGame({
    required String message,
    VoidCallback? onTap,
  }) {
    return ClutchNotificationStyle(
      title: 'NAIL-BITER!',
      subtitle: message,
      icon: Icons.trending_up_rounded,
      gradientColors: [
        DesignTokens.primaryPurple,
        DesignTokens.royalPurple,
      ],
      onTap: onTap,
    );
  }

  factory ClutchNotificationStyle.comeback({
    required String message,
    VoidCallback? onTap,
  }) {
    return ClutchNotificationStyle(
      title: 'COMEBACK TIME!',
      subtitle: message,
      icon: Icons.trending_up_rounded,
      gradientColors: [
        DesignTokens.emeraldGreen,
        DesignTokens.oceanTeal,
      ],
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space8,
      ),
      child: Material(
        elevation: DesignTokens.elevationMedium,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        shadowColor: gradientColors.first.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.space8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.9, 0.9),
            duration: 200.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(),
    );
  }
}
