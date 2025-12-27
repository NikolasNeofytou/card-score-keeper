// lib/state/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';
  static const String _useSystemKey = 'use_system_theme';

  ThemeController() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeStr = prefs.getString(_themeKey);
      final useSystem = prefs.getBool(_useSystemKey) ?? true;

      if (themeModeStr != null) {
        final themeMode = ThemeMode.values.byName(themeModeStr);
        state = ThemeState(themeMode: themeMode, useSystemTheme: useSystem);
      }
    } catch (e) {
      // Use default theme if loading fails
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode, useSystemTheme: false);
    await _saveTheme();
  }

  Future<void> toggleTheme() async {
    final newMode = state.isDark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setUseSystemTheme(bool useSystem) async {
    state = state.copyWith(useSystemTheme: useSystem);
    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, state.themeMode.name);
      await prefs.setBool(_useSystemKey, state.useSystemTheme);
    } catch (e) {
      // Ignore save errors
    }
  }
}
