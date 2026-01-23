// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import '../ui/theme/flex_color_theme.dart';
import '../state/providers.dart';
import '../ui/screens/game_lobby_screen.dart';
import '../ui/screens/qr_scanner_screen.dart';
import '../ui/screens/spectator_screen.dart';
import '../domain/models/game.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.useSystemTheme
        ? ThemeMode.system
        : themeState.themeMode;

    return MaterialApp.router(
      title: 'Card Game Scorekeeper',
      debugShowCheckedModeBanner: false,
      theme: FlexColorTheme.lightTheme,
      darkTheme: FlexColorTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
