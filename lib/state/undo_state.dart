// lib/state/undo_state.dart
import '../domain/models/game.dart';

/// Manages undo/redo functionality for game state
class UndoState {
  final List<Game> history;
  final int currentIndex;
  final int maxHistorySize;

  const UndoState({
    this.history = const [],
    this.currentIndex = -1,
    this.maxHistorySize = 50,
  });

  UndoState copyWith({
    List<Game>? history,
    int? currentIndex,
    int? maxHistorySize,
  }) =>
      UndoState(
        history: history ?? this.history,
        currentIndex: currentIndex ?? this.currentIndex,
        maxHistorySize: maxHistorySize ?? this.maxHistorySize,
      );

  bool get canUndo => currentIndex > 0;
  bool get canRedo => currentIndex < history.length - 1;

  Game? get currentState =>
      currentIndex >= 0 && currentIndex < history.length
          ? history[currentIndex]
          : null;

  /// Add a new state to history
  UndoState addState(Game game) {
    // Remove any states after current index (they're invalidated by this action)
    final newHistory = history.sublist(0, currentIndex + 1);
    
    // Add new state
    newHistory.add(game);
    
    // Trim history if it exceeds max size
    final trimmedHistory = newHistory.length > maxHistorySize
        ? newHistory.sublist(newHistory.length - maxHistorySize)
        : newHistory;
    
    return UndoState(
      history: trimmedHistory,
      currentIndex: trimmedHistory.length - 1,
      maxHistorySize: maxHistorySize,
    );
  }

  /// Move back in history
  UndoState undo() {
    if (!canUndo) return this;
    return copyWith(currentIndex: currentIndex - 1);
  }

  /// Move forward in history
  UndoState redo() {
    if (!canRedo) return this;
    return copyWith(currentIndex: currentIndex + 1);
  }

  /// Clear all history
  UndoState clear() {
    return const UndoState();
  }
}
