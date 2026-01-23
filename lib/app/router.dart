// lib/app/router.dart
import 'package:go_router/go_router.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/create_game_screen.dart';
import '../ui/screens/scoreboard_screen.dart';
import '../ui/screens/predictions_screen.dart';
import '../ui/screens/results_screen.dart';
import '../ui/screens/history_screen.dart';
import '../ui/screens/game_list_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/clutch_screen.dart';
import '../ui/screens/game_lobby_screen.dart';
import '../ui/screens/qr_scanner_screen.dart';
import '../ui/screens/spectator_screen.dart';
import '../domain/models/game.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateGameScreen(),
    ),
    GoRoute(
      path: '/scoreboard',
      builder: (context, state) => const ScoreboardScreen(),
    ),
    GoRoute(
      path: '/predictions',
      builder: (context, state) => const PredictionsScreen(),
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) => const ResultsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/games',
      builder: (context, state) => const GameListScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/clutch',
      builder: (context, state) => const ClutchScreen(),
    ),
    GoRoute(
      path: '/lobby',
      builder: (context, state) {
        final game = state.extra as Game?;
        if (game == null) {
          // Redirect to home if no game provided
          return const HomeScreen();
        }
        return GameLobbyScreen(game: game);
      },
    ),
    GoRoute(
      path: '/qr-scanner',
      builder: (context, state) => const QRScannerScreen(),
    ),
    GoRoute(
      path: '/spectator',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        if (args == null) {
          return const HomeScreen();
        }
        return SpectatorScreen(
          gameData: args['gameData'],
          serverUrl: args['serverUrl'],
          message: args['message'],
        );
      },
    ),
  ],
);
