import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/persistence/storage_models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register TypeAdapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(StoredGameAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(StoredGameSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(StoredPlayerAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(StoredGameRoundAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(StoredRoundEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(StoredGameInfoAdapter());
  }

  // Development mode: Clear data on every launch
  const bool isDevelopment =
      bool.fromEnvironment('DEVELOPMENT', defaultValue: false);
  if (isDevelopment) {
    print('🧹 Development mode: Clearing all data for fresh start...');
    try {
      await Hive.deleteBoxFromDisk('games');
      await Hive.deleteBoxFromDisk('app_v2');
      print('✅ Data cleared successfully');
    } catch (e) {
      print('ℹ️  No existing data to clear: $e');
    }
  }

  runApp(const ProviderScope(child: App()));
}
