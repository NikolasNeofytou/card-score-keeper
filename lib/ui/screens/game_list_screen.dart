import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../state/game_list_state.dart';
import '../../state/game_list_controller.dart';
import '../../state/providers.dart';
import '../theme/app_colors.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameListState = ref.watch(gameListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColorsDark : AppColors;
    
    final activeGames = gameListState.games
        .where((g) => g.status == GameStatus.active)
        .toList();
    final archivedGames = gameListState.games
        .where((g) => g.status == GameStatus.archived)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showNewGameDialog(context, ref),
            tooltip: 'New Game',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeGames.isNotEmpty) ...[
            _SectionHeader(
              title: 'Active Games',
              count: activeGames.length,
              colors: colors,
            ),
            const SizedBox(height: 12),
            ...activeGames.map((game) => _GameCard(
              game: game,
              isCurrent: game.id == gameListState.currentGameId,
              onTap: () => _switchToGame(context, ref, game.id),
              onArchive: () => _archiveGame(ref, game.id),
              onDelete: () => _confirmDelete(context, ref, game.id),
              colors: colors,
            )),
            const SizedBox(height: 24),
          ],
          if (archivedGames.isNotEmpty) ...[
            _SectionHeader(
              title: 'Archived Games',
              count: archivedGames.length,
              colors: colors,
            ),
            const SizedBox(height: 12),
            ...archivedGames.map((game) => _GameCard(
              game: game,
              isCurrent: false,
              onTap: () => _unarchiveGame(ref, game.id),
              onArchive: null,
              onDelete: () => _confirmDelete(context, ref, game.id),
              colors: colors,
            )),
          ],
        ],
      ),
    );
  }

  void _switchToGame(BuildContext context, WidgetRef ref, String gameId) async {
    try {
      await ref.read(gameListControllerProvider.notifier).switchToGame(gameId);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch game: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _archiveGame(WidgetRef ref, String gameId) async {
    try {
      await ref.read(gameListControllerProvider.notifier).archiveGame(gameId);
    } catch (e) {
      // Error will be shown by the state
    }
  }

  void _unarchiveGame(WidgetRef ref, String gameId) async {
    try {
      await ref.read(gameListControllerProvider.notifier).unarchiveGame(gameId);
    } catch (e) {
      // Error will be shown by the state
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String gameId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text('Are you sure you want to permanently delete this game? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(gameListControllerProvider.notifier).deleteGame(gameId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete game: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Game'),
        content: const Text('Create a new game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/create');
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final dynamic colors;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameInfo game;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final VoidCallback onDelete;
  final dynamic colors;

  const _GameCard({
    required this.game,
    required this.isCurrent,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              game.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.surface,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${game.playerCount} players',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colors.textSecondary),
                    onSelected: (value) {
                      switch (value) {
                        case 'archive':
                          onArchive?.call();
                          break;
                        case 'unarchive':
                          onTap();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (onArchive != null)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive_outlined),
                              SizedBox(width: 12),
                              Text('Archive'),
                            ],
                          ),
                        )
                      else
                        const PopupMenuItem(
                          value: 'unarchive',
                          child: Row(
                            children: [
                              Icon(Icons.unarchive_outlined),
                              SizedBox(width: 12),
                              Text('Unarchive'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${dateFormat.format(game.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.update, size: 14, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${dateFormat.format(game.lastModified)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
