// Fake path provider for tests
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp/test_documents';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return '/tmp/test_support';
  }

  @override
  Future<String?> getTemporaryPath() async {
    return '/tmp/test_temp';
  }

  @override
  Future<String?> getLibraryPath() async {
    return '/tmp/test_library';
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return '/tmp/test_cache';
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return '/tmp/test_external';
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return ['/tmp/test_external_cache'];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return ['/tmp/test_external_storage'];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return '/tmp/test_downloads';
  }
}
