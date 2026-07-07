import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppStoragePathsService {
  AppStoragePathsService._();

  static final AppStoragePathsService instance = AppStoragePathsService._();

  final String _rootName = 'Rose_School_edu';

  // ─── Root ──────────────────────────────────────────────────────────

  Future<Directory> get root async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _rootName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> get rootPath async {
    final r = await root;
    return r.path;
  }

  // ─── Sub-directories ───────────────────────────────────────────────

  Future<Directory> _ensureSub(String name) async {
    final r = await root;
    final dir = Directory(p.join(r.path, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> _subPath(String name) async {
    final d = await _ensureSub(name);
    return d.path;
  }

  Future<Directory> get dataDir async => _ensureSub('data');
  Future<String> get dataPath async => _subPath('data');

  Future<Directory> get filesDir async => _ensureSub('files');
  Future<String> get filesPath async => _subPath('files');

  Future<Directory> get backupsDir async => _ensureSub('backups');
  Future<String> get backupsPath async => _subPath('backups');

  Future<Directory> get reportsDir async => _ensureSub('reports');
  Future<String> get reportsPath async => _subPath('reports');

  Future<Directory> get configDir async => _ensureSub('config');
  Future<String> get configPath async => _subPath('config');

  // ─── Database path ─────────────────────────────────────────────────

  Future<String> get databasePath async {
    final data = await dataPath;
    return p.join(data, 'rose_school_2026.db');
  }

  // ─── Student files ─────────────────────────────────────────────────

  Future<Directory> studentFilesDir(int studentId) async {
    final files = await filesDir;
    final dir = Directory(p.join(files.path, 'students', studentId.toString()));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> studentBucketDir(int studentId, String bucket) async {
    final files = await filesDir;
    final dir = Directory(p.join(files.path, 'students', studentId.toString(), bucket));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ─── Employee files ────────────────────────────────────────────────

  Future<Directory> employeeFilesDir(int employeeId) async {
    final files = await filesDir;
    final dir = Directory(p.join(files.path, 'employees', employeeId.toString()));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ─── School assets (seal, signature, logo) ─────────────────────────

  Future<Directory> get schoolAssetsDir async {
    final files = await filesDir;
    final dir = Directory(p.join(files.path, 'school'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> get sealImagePath async {
    final assets = await schoolAssetsDir;
    return p.join(assets.path, 'seal.png');
  }

  Future<String> get signatureImagePath async {
    final assets = await schoolAssetsDir;
    return p.join(assets.path, 'signature.png');
  }

  // ─── Config file paths ─────────────────────────────────────────────

  Future<String> get settingsFilePath async {
    final cfg = await configDir;
    return p.join(cfg.path, 'settings.json');
  }

  // ─── Project file bucket (general purpose) ─────────────────────────

  Future<Directory> projectBucketDir(String bucket) async {
    final files = await filesDir;
    final dir = Directory(p.join(files.path, bucket));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ─── Utility: get total size of a directory ────────────────────────

  Future<int> directorySize(Directory dir) async {
    int total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  // ─── Utility: delete everything in root (for clean reset) ──────────

  Future<void> resetAll() async {
    final r = await root;
    if (await r.exists()) {
      await r.delete(recursive: true);
    }
  }
}
