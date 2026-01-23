// lib/ui/screens/create_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/providers.dart';

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
    if (_playerControllers.length < 8) {
      setState(() {
        _playerControllers.add(TextEditingController());
      });
    }
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
    print('Create game button pressed');

    if (_formKey.currentState?.validate() ?? false) {
      print('Form validation passed');
      _formKey.currentState?.save();

      final playerNames = _playerControllers
          .map((controller) => controller.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      print('Player names: $playerNames');

      if (playerNames.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('At least 2 players required')),
        );
        return;
      }

      // Check for duplicate names
      final uniqueNames = playerNames.toSet();
      if (uniqueNames.length != playerNames.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player names must be unique')),
        );
        return;
      }

      print(
          'Creating game with settings: peakCards=$_peakCards, bonusExact=$_bonusExact');

      try {
        await ref.read(gameControllerProvider.notifier).createGame(
              playerNames: playerNames,
              peakCards: _peakCards,
              bonusExact: _bonusExact,
              gameName: _gameName,
            );

        print('Game created successfully, navigating to scoreboard');

        if (mounted) {
          context.go('/scoreboard');
        }
      } catch (e) {
        print('Error creating game: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating game: $e')),
          );
        }
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Game Name Input
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Game Name (optional)',
                      hintText: 'Friday Night Game',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _gameName = value?.trim(),
                  ),
                  const SizedBox(height: 24),

                  // Players Section
                  Text(
                    'Players (${_playerControllers.length})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Player List
                  ...List.generate(_playerControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _playerControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Player ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Player name required';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_playerControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removePlayer(index),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Add Player Button - directly below player fields, aligned left
                  if (_playerControllers.length < 8) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _addPlayer,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Player'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Game Settings
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Peak Cards',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _peakCards.toString(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final val = int.tryParse(value ?? '');
                            if (val == null || val < 1 || val > 13) {
                              return '1-13 only';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _peakCards = int.tryParse(value ?? '7') ?? 7;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Exact Bonus',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _bonusExact.toString(),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final val = int.tryParse(value ?? '');
                            if (val == null || val < 0 || val > 50) {
                              return '0-50 only';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _bonusExact = int.tryParse(value ?? '10') ?? 10;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Create Game Button - not floating
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _createGame,
                      icon: const Icon(Icons.sports_esports),
                      label: const Text('Create Game'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
