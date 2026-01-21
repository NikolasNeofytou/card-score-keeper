// lib/state/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/game_repository.dart';
import '../data/hive_game_repository.dart';
import 'game_controller.dart';
import 'game_state.dart';
import 'game_list_controller.dart';
import 'game_list_state.dart';
import 'undo_controller.dart';
import 'undo_state.dart';
import 'theme_controller.dart';
import 'theme_state.dart';

// Repository Provider
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return HiveGameRepository();
});

// Game Controller Provider
final gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
  return GameController(
    ref.read(gameRepositoryProvider),
    ref.read(gameListControllerProvider.notifier),
  );
});

// Game List Controller Provider
final gameListControllerProvider =
    StateNotifierProvider<GameListController, GameListState>((ref) {
  return GameListController(ref.read(gameRepositoryProvider));
});

// Game List State Provider
final gameListProvider =
    StateNotifierProvider<GameListController, GameListState>((ref) {
  return ref.watch(gameListControllerProvider.notifier);
});

// Undo Controller Provider
final undoControllerProvider =
    StateNotifierProvider<UndoController, UndoState>((ref) {
  return UndoController();
});

// Theme Controller Provider
final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController();
});

// Theme State Provider
final themeProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ref.watch(themeControllerProvider.notifier);
});
