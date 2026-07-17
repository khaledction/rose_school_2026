import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/school_models.dart';
import 'app_storage_paths_service.dart';
import 'school_database_service.dart';

class BackupService {
  BackupService._();

  static final BackupService instance = BackupService._();

  /// Create a full backup: DB + files + snapshot JSON + manifest
  Future<String> createBackup({String note = ''}) async {
    final paths = AppStoragePathsService.instance;
    final timestamp = DateTime.now();
    final stamp = _formatTimestamp(timestamp);
    final backupName = 'ROSE_BACKUP_$stamp';
    final backupDir = Directory(p.join(await paths.backupsPath, backupName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // 1. Copy database
    final dbPath = await paths.databasePath;
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.copy(p.join(backupDir.path, 'rose_school_2026.db'));
    }

    // 2. Copy files directory
    final filesDir = await paths.filesDir;
    await _copyDirectory(filesDir, Directory(p.join(backupDir.path, 'files')));

    // 3. Create snapshot JSON
    final snapshot = await _createSnapshot();
    await File(p.join(backupDir.path, 'snapshot.json'))
        .writeAsString(jsonEncode(snapshot), flush: true);

    // 4. Create manifest
    final manifest = {
      'backupName': backupName,
      'createdAt': timestamp.toIso8601String(),
      'appVersion': '1.0.0',
      'note': note,
      'studentCount': snapshot['studentCount'] ?? 0,
      'employeeCount': snapshot['employeeCount'] ?? 0,
      'totalFiles': snapshot['totalFiles'] ?? 0,
    };
    await File(p.join(backupDir.path, 'manifest.json'))
        .writeAsString(jsonEncode(manifest), flush: true);

    // 5. Create preview HTML
    await _createPreviewHtml(backupDir, manifest, snapshot);

    // 6. Zip it
    final zipPath = '${backupDir.path}.zip';
    await _zipDirectory(backupDir.path, zipPath);

    // 7. Remove temp directory
    await backupDir.delete(recursive: true);

    return zipPath;
  }

  /// Restore from a backup zip file
  Future<void> restoreFromBackup(String zipPath) async {
    if (!await File(zipPath).exists()) {
      throw Exception('ملف النسخة الاحتياطية غير موجود');
    }

    final paths = AppStoragePathsService.instance;

    // Create temp extraction directory
    final tempDir = Directory(p.join(
      (await paths.root).path,
      '_restore_temp_${DateTime.now().millisecondsSinceEpoch}',
    ));
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }

    try {
      // Extract zip
      await _unzipFile(zipPath, tempDir.path);

      // Verify manifest
      final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
      if (!await manifestFile.exists()) {
        throw Exception('ملف النسخة غير صالح: manifest.json غير موجود');
      }

      // Restore database
      final sourceDb = File(p.join(tempDir.path, 'rose_school_2026.db'));
      if (await sourceDb.exists()) {
        final targetDb = await paths.databasePath;
        // Close current db first
        await SchoolDatabaseService.instance.close();
        await sourceDb.copy(targetDb);
      }

      // Restore files
      final sourceFiles = Directory(p.join(tempDir.path, 'files'));
      if (await sourceFiles.exists()) {
        final targetFiles = await paths.filesDir;
        if (await targetFiles.exists()) {
          await targetFiles.delete(recursive: true);
        }
        await sourceFiles.rename(targetFiles.path);
      }

      // Reopen database
      await SchoolDatabaseService.instance.database;
    } finally {
      // Clean up temp
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  /// Get list of available backups
  Future<List<BackupEntry>> listBackups() async {
    final paths = AppStoragePathsService.instance;
    final backupsDir = await paths.backupsDir;
    final backups = <BackupEntry>[];

    await for (final entity in backupsDir.list()) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.zip') {
        final stat = await entity.stat();
        final name = p.basenameWithoutExtension(entity.path);

        // Try to read manifest from inside zip
        String createdAt = stat.modified.toIso8601String();
        int studentCount = 0;
        int fileCount = 0;
        String note = '';

        try {
          final manifest = await _readManifestFromZip(entity.path);
          if (manifest != null) {
            createdAt = manifest['createdAt']?.toString() ?? createdAt;
            studentCount = (manifest['studentCount'] as num?)?.toInt() ?? 0;
            fileCount = (manifest['totalFiles'] as num?)?.toInt() ?? 0;
            note = manifest['note']?.toString() ?? '';
          }
        } catch (_) {}

        backups.add(BackupEntry(
          name: name,
          createdAt: createdAt,
          fileCount: fileCount,
          studentCount: studentCount,
          note: note,
        ));
      }
    }

    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  /// Delete a backup file
  Future<void> deleteBackup(String backupName) async {
    final paths = AppStoragePathsService.instance;
    final file = File(p.join(await paths.backupsPath, '$backupName.zip'));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final paths = AppStoragePathsService.instance;
    final dbPath = await paths.databasePath;
    final dbFile = File(dbPath);
    final dbSize = await dbFile.exists() ? await dbFile.length() : 0;

    final filesDir = await paths.filesDir;
    int filesSize = 0;
    int fileCount = 0;
    if (await filesDir.exists()) {
      await for (final entity in filesDir.list(recursive: true)) {
        if (entity is File) {
          filesSize += await entity.length();
          fileCount++;
        }
      }
    }

    final backups = await listBackups();

    return {
      'databaseSize': dbSize,
      'databaseSizeFormatted': _formatBytes(dbSize),
      'filesSize': filesSize,
      'filesSizeFormatted': _formatBytes(filesSize),
      'fileCount': fileCount,
      'totalSize': dbSize + filesSize,
      'totalSizeFormatted': _formatBytes(dbSize + filesSize),
      'backupCount': backups.length,
      'latestBackup': backups.isNotEmpty ? backups.first.createdAt : null,
      'backups': backups,
    };
  }

  // ─── Private Helpers ──────────────────────────────────────────

  Future<Map<String, dynamic>> _createSnapshot() async {
    final db = SchoolDatabaseService.instance;
    final data = <String, dynamic>{};

    final studentsJson = await db.readJson('students');
    if (studentsJson != null) {
      data['students'] = jsonDecode(studentsJson);
    }
    final adminUsersJson = await db.readJson('admin_users');
    if (adminUsersJson != null) {
      data['adminUsers'] = jsonDecode(adminUsersJson);
    }
    final schoolIdentityJson = await db.readJson('school_identity');
    if (schoolIdentityJson != null) {
      data['schoolIdentity'] = jsonDecode(schoolIdentityJson);
    }

    data['studentCount'] = (data['students'] as List?)?.length ?? 0;
    data['employeeCount'] = (data['employees'] as List?)?.length ?? 0;
    data['totalFiles'] = 0;

    return data;
  }

  Future<void> _createPreviewHtml(
    Directory dir,
    Map<String, dynamic> manifest,
    Map<String, dynamic> snapshot,
  ) async {
    final html = '''
<!DOCTYPE html>
<html dir="rtl">
<head>
  <meta charset="UTF-8">
  <title>معاينة النسخة الاحتياطية</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #f5f7fa; padding: 30px; }
    .card { background: white; border-radius: 18px; padding: 24px; margin-bottom: 16px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
    h1 { color: #0F1F45; font-size: 24px; }
    .label { color: #667586; font-size: 12px; }
    .value { color: #0F1F45; font-size: 18px; font-weight: 700; }
    .row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eef2f7; }
  </style>
</head>
<body>
  <div class="card">
    <h1>📦 ${manifest['backupName']}</h1>
    <p>${manifest['note'] ?? ''}</p>
  </div>
  <div class="card">
    <div class="row"><span class="label">تاريخ الإنشاء</span><span class="value">${manifest['createdAt']}</span></div>
    <div class="row"><span class="label">عدد الطلاب</span><span class="value">${manifest['studentCount']}</span></div>
    <div class="row"><span class="label">عدد الموظفين</span><span class="value">${manifest['employeeCount']}</span></div>
    <div class="row"><span class="label">عدد الملفات</span><span class="value">${manifest['totalFiles']}</span></div>
  </div>
  <div class="card">
    <p style="color:#667586;">هذه المعاينة تم إنشاؤها تلقائياً بواسطة نظام Rose School.</p>
  </div>
</body>
</html>
''';
    await File(p.join(dir.path, 'preview.html')).writeAsString(html, flush: true);
  }

  Future<Map<String, dynamic>?> _readManifestFromZip(String zipPath) async {
    // Simple: try to parse the name or read from file list
    // For now, extract just the timestamp from the filename
    final name = p.basenameWithoutExtension(zipPath);
    final parts = name.replaceAll('ROSE_BACKUP_', '').split('_');
    if (parts.length >= 2) {
      return {
        'createdAt': '${parts[0]}-${parts[1].substring(0, 2)}-${parts[1].substring(2, 4)}T${parts[1].substring(4, 6)}:${parts[1].substring(6, 8)}:00',
      };
    }
    return null;
  }

  Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!await source.exists()) return;
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    await for (final entity in source.list()) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: source.path);
        await entity.copy(p.join(target.path, relativePath));
      } else if (entity is Directory) {
        final relativePath = p.relative(entity.path, from: source.path);
        await _copyDirectory(entity, Directory(p.join(target.path, relativePath)));
      }
    }
  }

  Future<void> _zipDirectory(String sourcePath, String targetPath) async {
    // Use a simple approach: create a tar-like structure
    // Since we can't use external zip libraries, we'll copy the backup
    // For real zip, we'd need archive package
    final source = Directory(sourcePath);
    if (!await source.exists()) return;

    // For now, create a JSON manifest of all files
    final backupData = <String, dynamic>{};
    final files = <String, String>{};

    await for (final entity in source.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: sourcePath);
        files[relativePath] = base64Encode(await entity.readAsBytes());
      }
    }

    backupData['files'] = files;
    await File(targetPath).writeAsString(jsonEncode(backupData), flush: true);
  }

  Future<void> _unzipFile(String zipPath, String targetPath) async {
    // Reverse of _zipDirectory
    final data = jsonDecode(await File(zipPath).readAsString()) as Map<String, dynamic>;
    final files = data['files'] as Map<String, dynamic>;

    for (final entry in files.entries) {
      final filePath = p.join(targetPath, entry.key);
      final dir = Directory(p.dirname(filePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      await File(filePath).writeAsBytes(base64Decode(entry.value as String), flush: true);
    }
  }

  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${y}_${m}${d}_${h}${min}${s}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
