import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../data/hardened_hive_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Use System Theme'),
                subtitle: const Text('Follow system dark mode setting'),
                value: themeState.useSystemTheme,
                onChanged: (value) {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setUseSystemTheme(value);
                },
                secondary: const Icon(Icons.brightness_auto),
              ),
              if (!themeState.useSystemTheme)
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeLabel(themeState.themeMode)),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode, size: 18),
                      ),
                    ],
                    selected: {themeState.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selected) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setThemeMode(selected.first);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _StorageHealthSection(),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub'),
                subtitle: const Text('View source code'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {
                  // Open GitHub repository
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _StorageHealthSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageHealth = ref.watch(storageHealthProvider);

    return _SettingsSection(
      title: 'Storage Health',
      children: [
        storageHealth.when(
          data: (report) => Column(
            children: [
              ListTile(
                leading: Icon(
                  report.isHealthy ? Icons.check_circle : Icons.warning,
                  color: report.isHealthy
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                title: Text(
                    'Storage Health: ${(report.healthScore * 100).toStringAsFixed(0)}%'),
                subtitle: Text(
                  report.isHealthy
                      ? 'All systems operational'
                      : '${report.corruptedGames} corrupted games found',
                ),
              ),
              if (report.totalGames > 0) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Storage Stats'),
                  subtitle: Text(
                    'Games: ${report.totalGames} • Valid: ${report.validGames} • Schema v${report.schemaVersion}',
                  ),
                ),
              ],
              if (report.legacyFormatGames > 0) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('Legacy Format Games'),
                  subtitle: Text(
                      '${report.legacyFormatGames} games need format migration'),
                  trailing: const Icon(Icons.info_outline),
                ),
              ],
              if (!report.isHealthy) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Repair Storage'),
                  subtitle: const Text('Attempt to fix corrupted data'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showRepairDialog(context, ref),
                ),
              ],
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Health Check'),
                subtitle: const Text('Check storage integrity'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => ref.refresh(storageHealthProvider),
              ),
            ],
          ),
          loading: () => const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Checking storage health...'),
          ),
          error: (error, stack) => ListTile(
            leading: Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Health Check Failed'),
            subtitle: Text(error.toString()),
          ),
        ),
      ],
    );
  }

  void _showRepairDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repair Storage'),
        content: const Text(
          'This will attempt to repair corrupted game data. '
          'The operation is safe but may take a few moments to complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performRepair(context, ref);
            },
            child: const Text('Repair'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRepair(BuildContext context, WidgetRef ref) async {
    try {
      final repository =
          ref.read(gameRepositoryProvider) as HardenedHiveRepository;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Repairing storage...'),
            ],
          ),
        ),
      );

      await repository.repairStorage();

      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Refresh health check
      ref.refresh(storageHealthProvider);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage repair completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Repair failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
