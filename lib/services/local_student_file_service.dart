import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:qr/qr.dart';

import 'app_storage_paths_service.dart';

class LocalStudentFileService {
  LocalStudentFileService._();

  static final LocalStudentFileService instance = LocalStudentFileService._();

  Directory? _rootDirectory;

  Future<Directory> get rootDirectory async {
    _rootDirectory ??= await _resolveRootDirectory();
    return _rootDirectory!;
  }

  Future<Directory> _resolveRootDirectory() async {
    final dir = await AppStoragePathsService.instance.filesDir;
    return dir;
  }

  Future<Directory> _ensureStudentBucket(int studentId, String bucket) async {
    final root = await rootDirectory;
    final dir = Directory(p.join(root.path, 'students', studentId.toString(), bucket));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _ensureProjectBucket(String bucket) async {
    final root = await rootDirectory;
    final dir = Directory(p.join(root.path, bucket));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> saveFile({
    required int studentId,
    required String bucket,
    required String originalName,
    Uint8List? bytes,
    String? sourcePath,
    String? preferredBaseName,
  }) async {
    if ((bytes == null || bytes.isEmpty) && (sourcePath == null || sourcePath.trim().isEmpty)) {
      throw ArgumentError('Either bytes or sourcePath must be provided.');
    }

    final dir = await _ensureStudentBucket(studentId, bucket);
    final nameSource = originalName.isNotEmpty
        ? originalName
        : (sourcePath == null || sourcePath.trim().isEmpty ? 'file.bin' : p.basename(sourcePath!));
    final extension = p.extension(nameSource).isEmpty ? '.bin' : p.extension(nameSource).toLowerCase();
    final baseName = _slugify(
      preferredBaseName == null || preferredBaseName.trim().isEmpty
          ? p.basenameWithoutExtension(nameSource)
          : preferredBaseName,
    );
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = sha1
        .convert(utf8.encode('$studentId|$bucket|$nameSource|$timestamp'))
        .toString()
        .substring(0, 10);
    final file = File(p.join(dir.path, '${baseName}_${timestamp}_${hash}$extension'));

    if (bytes != null && bytes.isNotEmpty) {
      await file.writeAsBytes(bytes, flush: true);
    } else {
      final source = File(sourcePath!.trim());
      if (!await source.exists()) {
        throw FileSystemException('Source file does not exist.', source.path);
      }
      await source.copy(file.path);
    }

    return file.path;
  }

  Future<String> saveProjectFile({
    required String bucket,
    required String originalName,
    Uint8List? bytes,
    String? sourcePath,
    String? preferredBaseName,
  }) async {
    if ((bytes == null || bytes.isEmpty) && (sourcePath == null || sourcePath.trim().isEmpty)) {
      throw ArgumentError('Either bytes or sourcePath must be provided.');
    }

    final dir = await _ensureProjectBucket(bucket);
    final nameSource = originalName.isNotEmpty
        ? originalName
        : (sourcePath == null || sourcePath.trim().isEmpty ? 'file.bin' : p.basename(sourcePath!));
    final extension = p.extension(nameSource).isEmpty ? '.bin' : p.extension(nameSource).toLowerCase();
    final baseName = _slugify(
      preferredBaseName == null || preferredBaseName.trim().isEmpty
          ? p.basenameWithoutExtension(nameSource)
          : preferredBaseName,
    );
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = sha1
        .convert(utf8.encode('project|$bucket|$nameSource|$timestamp'))
        .toString()
        .substring(0, 10);
    final file = File(p.join(dir.path, '${baseName}_${timestamp}_${hash}$extension'));

    if (bytes != null && bytes.isNotEmpty) {
      await file.writeAsBytes(bytes, flush: true);
    } else {
      final source = File(sourcePath!.trim());
      if (!await source.exists()) {
        throw FileSystemException('Source file does not exist.', source.path);
      }
      await source.copy(file.path);
    }

    return file.path;
  }

  Future<String> writeTextFile({
    required int studentId,
    required String bucket,
    required String baseName,
    required String content,
    String extension = '.txt',
  }) async {
    final dir = await _ensureStudentBucket(studentId, bucket);
    final normalizedExtension = extension.startsWith('.') ? extension : '.$extension';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = sha1
        .convert(utf8.encode('$studentId|$bucket|$baseName|$timestamp'))
        .toString()
        .substring(0, 10);
    final file = File(
      p.join(
        dir.path,
        '${_slugify(baseName)}_${timestamp}_${hash}${normalizedExtension.toLowerCase()}',
      ),
    );
    await file.writeAsString(content, flush: true);
    return file.path;
  }

  Future<String> generateStudentQrSvg({
    required int studentId,
    required String payload,
    required String serial,
  }) async {
    final qrCode = QrCode.fromData(
      data: payload,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final qrImage = QrImage(qrCode);
    const cellSize = 8;
    const padding = 16;
    final moduleCount = qrImage.moduleCount;
    final canvasSize = moduleCount * cellSize + padding * 2;
    final svg = StringBuffer()
      ..writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" width="$canvasSize" height="$canvasSize" viewBox="0 0 $canvasSize $canvasSize">',
      )
      ..writeln('<rect width="$canvasSize" height="$canvasSize" rx="18" ry="18" fill="#FFFFFF"/>');

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (!qrImage.isDark(row, col)) {
          continue;
        }
        final x = padding + col * cellSize;
        final y = padding + row * cellSize;
        svg.writeln(
          '<rect x="$x" y="$y" width="$cellSize" height="$cellSize" fill="#000000"/>',
        );
      }
    }

    svg.writeln('</svg>');

    return writeTextFile(
      studentId: studentId,
      bucket: 'qr',
      baseName: 'qr_$serial',
      content: svg.toString(),
      extension: '.svg',
    );
  }

  Future<bool> fileExists(String? path) async {
    final normalized = path?.trim() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    return File(normalized).exists();
  }

  bool fileExistsSync(String? path) {
    final normalized = path?.trim() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    return File(normalized).existsSync();
  }

  Future<int> fileSize(String? path) async {
    final normalized = path?.trim() ?? '';
    if (normalized.isEmpty) {
      return 0;
    }
    final file = File(normalized);
    if (!await file.exists()) {
      return 0;
    }
    return file.length();
  }

  Future<void> deleteFile(String? path) async {
    final normalized = path?.trim() ?? '';
    if (normalized.isEmpty) {
      return;
    }
    final file = File(normalized);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteStudentDirectory(int studentId) async {
    final root = await rootDirectory;
    final dir = Directory(p.join(root.path, 'students', studentId.toString()));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  String fileNameFromPath(String? path) {
    final normalized = path?.trim() ?? '';
    if (normalized.isEmpty) {
      return '';
    }
    return p.basename(normalized);
  }

  String _slugify(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'file';
    }
    final normalized = trimmed
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized.isEmpty ? 'file' : normalized;
  }
}
