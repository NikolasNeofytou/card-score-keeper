// lib/state/theme_state.dart
import 'package:flutter/material.dart';

/// Manages theme preferences
class ThemeState {
  final ThemeMode themeMode;
  final bool useSystemTheme;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.useSystemTheme = true,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? useSystemTheme,
  }) =>
      ThemeState(
        themeMode: themeMode ?? this.themeMode,
        useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      );

  bool get isDark => themeMode == ThemeMode.dark;

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'useSystemTheme': useSystemTheme,
      };

  factory ThemeState.fromJson(Map<String, dynamic> json) => ThemeState(
        themeMode: ThemeMode.values.byName(json['themeMode'] as String),
        useSystemTheme: json['useSystemTheme'] as bool,
      );
}
