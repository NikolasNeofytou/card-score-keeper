import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../state/game_list_state.dart';
import '../../state/game_list_controller.dart';
import '../../state/providers.dart';
import '../theme/design_tokens.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameListState = ref.watch(gameListControllerProvider);
    final gameListController = ref.read(gameListControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Card Games',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => context.push('/create-game'),
            icon: Icon(
              Icons.add_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            tooltip: 'Create New Game',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: gameListState.isLoading
          ? _buildLoadingState(context)
          : gameListState.error != null
              ? _buildErrorState(context, gameListState.error!)
              : _buildGameList(context, ref, gameListState, colorScheme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-game'),
        backgroundColor: DesignTokens.primaryPurple,
        elevation: 4,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ).animate().scale(
            duration: 200.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildGameList(BuildContext context, WidgetRef ref,
      GameListState gameListState, ColorScheme colorScheme) {
    final activeGames = gameListState.games
        .where((g) => g.status == GameStatus.active)
        .toList();
    final archivedGames = gameListState.games
        .where((g) => g.status == GameStatus.archived)
        .toList();

    if (activeGames.isEmpty && archivedGames.isEmpty) {
      return _buildEmptyState(context, colorScheme);
    }

    final gameListController = ref.read(gameListControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async => gameListController.refreshGameList(),
      color: DesignTokens.primaryPurple,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (activeGames.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _GameSection(
                title: 'Active Games',
                count: activeGames.length,
                colorScheme: colorScheme,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = activeGames[index];
                  return _GameCard(
                    key: ValueKey(game.id),
                    game: game,
                    onArchive: () => gameListController.archiveGame(game.id),
                    onDelete: () =>
                        _showDeleteDialog(context, game, gameListController),
                  );
                },
                childCount: activeGames.length,
              ),
            ),
          ],

          if (archivedGames.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _GameSection(
                title: 'Archived Games',
                count: archivedGames.length,
                colorScheme: colorScheme,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = archivedGames[index];
                  return _GameCard(
                    key: ValueKey(game.id),
                    game: game,
                    onUnarchive: () =>
                        gameListController.unarchiveGame(game.id),
                    onDelete: () =>
                        _showDeleteDialog(context, game, gameListController),
                  );
                },
                childCount: archivedGames.length,
              ),
            ),
          ],

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.space24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.casino_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Text(
              'No Games Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              'Create your first game to start keeping score!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space32),
            FilledButton.icon(
              onPressed: () => context.push('/create-game'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Game'),
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space24,
                  vertical: DesignTokens.space16,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignTokens.errorPrimary,
            ),
            const SizedBox(height: DesignTokens.space16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: DesignTokens.errorPrimary,
                  ),
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    GameInfo game,
    gameListController,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text(
            'Are you sure you want to delete "${game.name ?? 'this game'}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              gameListController.deleteGame(game.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.errorPrimary,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GameSection extends StatelessWidget {
  final String title;
  final int count;
  final ColorScheme colorScheme;

  const _GameSection({
    required this.title,
    required this.count,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space12,
      ),
      margin: const EdgeInsets.only(bottom: DesignTokens.space16),
      child: Row(
        children: [
          Icon(
            title == 'Active Games'
                ? Icons.play_circle_outline
                : Icons.archive_outlined,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: DesignTokens.space8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space8,
              vertical: DesignTokens.space4,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends ConsumerWidget {
  const _GameCard({
    super.key,
    required this.game,
    this.onArchive,
    this.onUnarchive,
    required this.onDelete,
  });

  final GameInfo game;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = game.status == GameStatus.active;
    final backgroundColor = isActive
        ? DesignTokens.successPrimary.withOpacity(0.1)
        : colorScheme.surfaceVariant.withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: DesignTokens.space8,
      ),
      child: Card(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        child: InkWell(
          onTap: () => context.push('/game/${game.id}'),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              border: Border.all(
                color: isActive
                    ? DesignTokens.successPrimary.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.1),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        game.name ?? 'Unnamed Game',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space8,
                            vertical: DesignTokens.space4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusSmall),
                          ),
                          child: Text(
                            game.status.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space8),
                        // Menu Button
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'archive':
                                onArchive?.call();
                                break;
                              case 'unarchive':
                                onUnarchive?.call();
                                break;
                              case 'delete':
                                onDelete();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (onArchive != null)
                              PopupMenuItem(
                                value: 'archive',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.archive_outlined,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: DesignTokens.space8),
                                    const Text('Archive'),
                                  ],
                                ),
                              )
                            else if (onUnarchive != null)
                              PopupMenuItem(
                                value: 'unarchive',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.unarchive_outlined,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: DesignTokens.space8),
                                    const Text('Unarchive'),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: DesignTokens.errorPrimary,
                                  ),
                                  const SizedBox(width: DesignTokens.space8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: DesignTokens.errorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(
                            Icons.more_vert,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space12),

                // Game Info Row
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: DesignTokens.space4),
                    Text(
                      '${game.playerCount} players',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (game.totalRounds > 0) ...[
                      const SizedBox(width: DesignTokens.space16),
                      Icon(
                        Icons.casino_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: DesignTokens.space4),
                      Text(
                        '${game.currentRound}/${game.totalRounds} rounds',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.update,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: DesignTokens.space4),
                    Text(
                      DateFormat('MMM d').format(game.lastModified),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),

                if (game.playerNames.isNotEmpty) ...[
                  const SizedBox(height: DesignTokens.space12),
                  // Player Names Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.space6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.space8),
                      Expanded(
                        child: Text(
                          game.playerNames.join(', '),
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: 0.2,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }

  Color _getStatusColor() {
    switch (game.status) {
      case GameStatus.active:
        return DesignTokens.successPrimary;
      case GameStatus.completed:
        return DesignTokens.primaryPurple;
      case GameStatus.archived:
        return DesignTokens.gray400;
    }
  }
}
