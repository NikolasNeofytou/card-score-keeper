// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../state/game_controller.dart';
import '../theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show error snackbar if there's an error
    if (gameState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(gameState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      });
    }

    // Show loading indicator
    if (gameState.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading game...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list_outlined),
            onPressed: () => context.push('/games'),
            tooltip: 'My Games',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        color: isDark ? AppColorsDark.background : AppColors.background,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Simple Trophy Icon
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Card Game Scorekeeper',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Track scores and predict winners',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Action Buttons
                  if (gameState.currentGame != null) ...[
                    _buildButton(
                      context: context,
                      label: 'Resume Game',
                      icon: Icons.play_arrow,
                      gradient: AppColors.gradientPrimary,
                      onPressed: () => context.go('/scoreboard'),
                      isPrimary: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).scale(),
                    
                    const SizedBox(height: 16),
                    
                    _buildButton(
                      context: context,
                      label: 'New Game',
                      icon: Icons.add,
                      gradient: AppColors.gradientSecondary,
                      onPressed: () => context.go('/create'),
                      isPrimary: false,
                    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).scale(),
                    
                    const SizedBox(height: 16),
                    
                    _buildButton(
                      context: context,
                      label: 'History',
                      icon: Icons.history,
                      gradient: LinearGradient(
                        colors: [AppColors.textSecondary, AppColors.textTertiary],
                      ),
                      onPressed: () => context.go('/history'),
                      isPrimary: false,
                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).scale(),
                  ] else ...[
                    _buildButton(
                      context: context,
                      label: 'Start New Game',
                      icon: Icons.add,
                      gradient: AppColors.gradientPrimary,
                      onPressed: () => context.go('/create'),
                      isPrimary: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).scale(),
                    
                    const SizedBox(height: 16),
                    
                    _buildButton(
                      context: context,
                      label: 'View History',
                      icon: Icons.history,
                      gradient: AppColors.gradientSecondary,
                      onPressed: () => context.go('/history'),
                      isPrimary: false,
                    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).scale(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.success : AppColors.surface,
          foregroundColor: isPrimary ? Colors.white : AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
