// lib/state/undo_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/game.dart';
import 'undo_state.dart';

class UndoController extends StateNotifier<UndoState> {
  UndoController() : super(const UndoState());

  /// Record a new state for undo/redo
  void recordState(Game game) {
    state = state.addState(game);
  }

  /// Undo the last action
  Game? undo() {
    if (!state.canUndo) return null;
    state = state.undo();
    return state.currentState;
  }

  /// Redo the last undone action
  Game? redo() {
    if (!state.canRedo) return null;
    state = state.redo();
    return state.currentState;
  }

  /// Clear all history
  void clear() {
    state = state.clear();
  }

  /// Get current state without modifying
  Game? get currentState => state.currentState;
}
