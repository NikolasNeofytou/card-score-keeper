// lib/ui/screens/create_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../state/providers.dart';
import '../widgets/number_stepper.dart';
import '../theme/app_colors.dart';
import '../widgets/animated/player_avatar.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerControllers = <TextEditingController>[];
  int _peakCards = 7;
  int _bonusExact = 10;
  String? _gameName;

  @override
  void initState() {
    super.initState();
    // Start with 2 players
    _playerControllers.add(TextEditingController());
    _playerControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _playerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    setState(() {
      _playerControllers.add(TextEditingController());
    });
  }

  void _removePlayer(int index) {
    if (_playerControllers.length > 2) {
      setState(() {
        _playerControllers[index].dispose();
        _playerControllers.removeAt(index);
      });
    }
  }

  Future<void> _createGame() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final playerNames = _playerControllers
          .map((c) => c.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      if (playerNames.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('At least 2 players required')),
        );
        return;
      }

      await ref.read(gameControllerProvider.notifier).createGame(
            playerNames: playerNames,
            peakCards: _peakCards,
            bonusExact: _bonusExact,
            gameName: _gameName,
          );

      if (mounted) {
        context.go('/scoreboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Game'),
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Game Name Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Game Name (optional)',
                      hintText: 'Friday Night Game',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                      prefixIcon: Icon(Icons.sports_esports,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    onSaved: (value) => _gameName = value?.trim(),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Players',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 12),
              ..._playerControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        PlayerAvatar(
                          name: controller.text.isEmpty
                              ? 'P${index + 1}'
                              : controller.text,
                          colorIndex: index,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Player ${index + 1}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.getPlayerColor(index),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter player name';
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        if (_playerControllers.length > 2)
                          IconButton(
                            icon: Icon(Icons.remove_circle,
                                color: AppColors.error),
                            onPressed: () => _removePlayer(index),
                          ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (200 + index * 50).ms)
                    .slideX(begin: -0.2, end: 0);
              }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addPlayer,
                icon: Icon(Icons.add, size: 18),
                label: Text('Add Player'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 24),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      NumberStepper(
                        label: 'Peak Cards',
                        value: _peakCards,
                        min: 2,
                        max: 13,
                        onChanged: (value) =>
                            setState(() => _peakCards = value),
                      ),
                      const SizedBox(height: 20),
                      NumberStepper(
                        label: 'Bonus Points',
                        value: _bonusExact,
                        min: 0,
                        max: 20,
                        onChanged: (value) =>
                            setState(() => _bonusExact = value),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).scale(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createGame,
                  icon: Icon(Icons.check_circle, size: 20),
                  label: Text('Create Game'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms).scale(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
