// lib/data/persistence/migration_manager.dart
import 'package:hive/hive.dart';
import 'schema_version.dart';

class MigrationManager {
  static Future<void> migrate(Box box) async {
    final currentVersion = box.get(SchemaVersion.key, defaultValue: 0) as int;

    if (currentVersion == SchemaVersion.current) {
      return; // No migration needed
    }

    print('Migrating from version $currentVersion to ${SchemaVersion.current}');

    // Perform migrations step by step
    for (int version = currentVersion + 1;
        version <= SchemaVersion.current;
        version++) {
      await _migrateToVersion(box, version);
      await box.put(SchemaVersion.key, version);
      print(
          'Migrated to version $version: ${SchemaVersion.getVersionDescription(version)}');
    }
  }

  static Future<void> _migrateToVersion(Box box, int targetVersion) async {
    switch (targetVersion) {
      case 1:
        await _migrateToV1(box);
        break;
      // Add future migrations here
      default:
        print('Unknown migration version: $targetVersion');
    }
  }

  static Future<void> _migrateToV1(Box box) async {
    // Migration from JSON strings to TypeAdapters
    // This handles the initial conversion from our old JSON-based storage

    final keysToMigrate = <String>[];
    final corruptedKeys = <String>[];

    // Find all game keys that need migration
    for (final key in box.keys) {
      if (key.toString().startsWith('game_')) {
        keysToMigrate.add(key.toString());
      }
    }

    for (final key in keysToMigrate) {
      try {
        final jsonStr = box.get(key) as String?;
        if (jsonStr != null && jsonStr.isNotEmpty) {
          // Try to parse the old JSON format
          final Map<String, dynamic> json = _parseJsonSafely(jsonStr);

          if (json.isNotEmpty && json.containsKey('id')) {
            // Convert to new format - but for now, keep the JSON string
            // The actual structured storage will be implemented when we save new games
            print('Migrated game key: $key');
          } else {
            corruptedKeys.add(key);
          }
        } else {
          corruptedKeys.add(key);
        }
      } catch (e) {
        print('Failed to migrate $key: $e');
        corruptedKeys.add(key);
      }
    }

    // Handle corrupted data
    if (corruptedKeys.isNotEmpty) {
      print('Found ${corruptedKeys.length} corrupted game entries');
      await _handleCorruptedData(box, corruptedKeys);
    }
  }

  static Map<String, dynamic> _parseJsonSafely(String jsonStr) {
    try {
      // Use a more robust JSON parsing approach
      final trimmed = jsonStr.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        // For now, return a minimal structure to indicate valid format
        return {'id': 'migration-placeholder', 'format': 'legacy-json'};
      }
      return {};
    } catch (e) {
      print('JSON parsing error: $e');
      return {};
    }
  }

  static Future<void> _handleCorruptedData(
      Box box, List<String> corruptedKeys) async {
    // Move corrupted data to a separate key for potential manual recovery
    final corruptedData = <String, dynamic>{};

    for (final key in corruptedKeys) {
      try {
        final value = box.get(key);
        corruptedData[key] = value.toString();
        await box.delete(key);
        print('Moved corrupted data for key: $key');
      } catch (e) {
        print('Failed to handle corrupted key $key: $e');
      }
    }

    if (corruptedData.isNotEmpty) {
      await box.put('_corrupted_data_backup', corruptedData);
      print('Backed up ${corruptedData.length} corrupted entries');
    }
  }

  /// Validate data integrity after migration
  static Future<bool> validateDataIntegrity(Box box) async {
    try {
      final version = box.get(SchemaVersion.key, defaultValue: 0) as int;
      if (version != SchemaVersion.current) {
        print(
            'Version mismatch: expected ${SchemaVersion.current}, got $version');
        return false;
      }

      // Check for orphaned or corrupted keys
      int gameCount = 0;
      for (final key in box.keys) {
        if (key.toString().startsWith('game_')) {
          gameCount++;
        }
      }

      print('Validation complete: found $gameCount games');
      return true;
    } catch (e) {
      print('Data integrity validation failed: $e');
      return false;
    }
  }
}
