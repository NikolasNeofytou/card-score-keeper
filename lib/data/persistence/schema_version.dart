// lib/data/persistence/schema_version.dart
class SchemaVersion {
  static const int current = 1;
  static const String key = 'schema_version';

  static const Map<int, String> versionHistory = {
    1: 'Initial schema with Game, Player, Round, GameSettings models',
  };

  static String getVersionDescription(int version) {
    return versionHistory[version] ?? 'Unknown version';
  }
}
