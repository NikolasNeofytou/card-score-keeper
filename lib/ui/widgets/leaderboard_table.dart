// lib/ui/widgets/leaderboard_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../state/game_state.dart';
import '../theme/design_tokens.dart';
import 'animated/player_avatar.dart';
import 'animated/trophy_icon.dart';
import 'animated/animated_score.dart';

/// Modern Gaming-Style Leaderboard Component
class LeaderboardTable extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final bool isGameFinished;

  const LeaderboardTable({
    super.key,
    required this.entries,
    this.isGameFinished = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(DesignTokens.space20),
            child: Row(
              children: [
                Icon(
                  Icons.leaderboard_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: DesignTokens.space12),
                Text(
                  isGameFinished ? 'Final Results' : 'Leaderboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (isGameFinished) ...[
                  const Spacer(),
                  Icon(
                    Icons.celebration_outlined,
                    color: DesignTokens.goldPrimary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),

          // Leaderboard entries
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                indent: DesignTokens.space20,
                endIndent: DesignTokens.space20,
              ),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final rank = index + 1;
                final isWinner = rank == 1 && isGameFinished;
                final isPodium = rank <= 3;

                return _buildLeaderboardRow(
                  context,
                  entry,
                  rank,
                  isWinner,
                  isPodium,
                  index,
                );
              },
            ),
          ),

          const SizedBox(height: DesignTokens.space8),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.2,
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildLeaderboardRow(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    bool isWinner,
    bool isPodium,
    int index,
  ) {
    final scoreColor = _getScoreColor(context, entry.totalPoints);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space20,
        vertical: DesignTokens.space16,
      ),
      decoration: BoxDecoration(
        gradient: isWinner
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  DesignTokens.goldPrimary.withOpacity(0.1),
                  Colors.transparent,
                ],
              )
            : null,
        borderRadius: index == 0
            ? const BorderRadius.only(
                topLeft: Radius.circular(DesignTokens.radiusXLarge),
                topRight: Radius.circular(DesignTokens.radiusXLarge),
              )
            : index == entries.length - 1
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(DesignTokens.radiusXLarge),
                    bottomRight: Radius.circular(DesignTokens.radiusXLarge),
                  )
                : null,
      ),
      child: Row(
        children: [
          // Rank with trophy/medal
          SizedBox(
            width: 40,
            child: Center(
              child: isPodium
                  ? TrophyIcon(
                      rank: rank,
                      size: rank == 1 ? 28 : 24,
                    )
                  : Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusSmall),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: DesignTokens.space16),

          // Player info
          Flexible(
            child: Row(
              children: [
                PlayerAvatar(
                  name: entry.player.name,
                  colorIndex: index % DesignTokens.playerColorSets.length,
                  size: 40,
                  showBorder: isWinner,
                  isWinner: isWinner,
                ),
                const SizedBox(width: DesignTokens.space12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.player.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  isWinner ? FontWeight.w700 : FontWeight.w600,
                              color: isWinner ? DesignTokens.goldPrimary : null,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isPodium && isGameFinished)
                        Text(
                          _getRankDescription(rank),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getRankColor(rank),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space12,
              vertical: DesignTokens.space6,
            ),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            ),
            child: AnimatedScore(
              score: entry.totalPoints,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    )
        .animate(
          delay: (index * 100).ms,
        )
        .slideX(
          begin: 0.3,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn();
  }

  Color _getScoreColor(BuildContext context, int score) {
    if (score > 0) return DesignTokens.successPrimary;
    if (score < 0) return DesignTokens.errorPrimary;
    return Theme.of(context).colorScheme.onSurface;
  }

  String _getRankDescription(int rank) {
    switch (rank) {
      case 1:
        return 'Champion';
      case 2:
        return 'Runner-up';
      case 3:
        return 'Third place';
      default:
        return '';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return DesignTokens.goldPrimary;
      case 2:
        return DesignTokens.silverPrimary;
      case 3:
        return DesignTokens.bronzePrimary;
      default:
        return DesignTokens.gray500;
    }
  }
}
