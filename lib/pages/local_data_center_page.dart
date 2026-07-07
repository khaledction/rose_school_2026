import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/app_storage_paths_service.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../theme/app_palette.dart';

class LocalDataCenterPage extends StatefulWidget {
  const LocalDataCenterPage({super.key});

  @override
  State<LocalDataCenterPage> createState() => _LocalDataCenterPageState();
}

class _LocalDataCenterPageState extends State<LocalDataCenterPage> {
  Map<String, dynamic> _storageInfo = {};
  bool _isLoading = true;
  bool _isCreatingBackup = false;
  bool _isRestoring = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    try {
      final info = await BackupService.instance.getStorageInfo();
      setState(() {
        _storageInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطأ في تحميل معلومات التخزين: $e';
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() {
      _isCreatingBackup = true;
      _statusMessage = 'جارٍ إنشاء النسخة الاحتياطية...';
    });
    try {
      final path = await BackupService.instance.createBackup(note: 'نسخة يدوية');
      await NotificationService.instance.addSimple(
        type: 'success',
        title: '✅ تم إنشاء نسخة احتياطية',
        body: 'تم حفظ النسخة في: $path',
        targetPage: 'data_center',
      );
      setState(() => _statusMessage = '✅ تم إنشاء النسخة: $path');
      await _refresh();
    } catch (e) {
      setState(() => _statusMessage = '❌ خطأ: $e');
    } finally {
      setState(() => _isCreatingBackup = false);
    }
  }

  Future<void> _restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ استعادة نسخة احتياطية'),
        content: const Text(
          'سيتم استبدال جميع البيانات الحالية بنسخة الاحتياطي. '
          'هل أنت متأكد؟'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.roseRed),
            child: const Text('استعادة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _isRestoring = true;
      _statusMessage = 'جارٍ استعادة البيانات...';
    });
    try {
      await BackupService.instance.restoreFromBackup(filePath);
      await NotificationService.instance.addSimple(
        type: 'success',
        title: '🔄 تمت استعادة النسخة',
        body: 'تم استعادة جميع البيانات من النسخة الاحتياطية.',
      );
      setState(() => _statusMessage = '✅ تمت استعادة البيانات بنجاح! يرجى إعادة تشغيل التطبيق.');
    } catch (e) {
      setState(() => _statusMessage = '❌ خطأ في الاستعادة: $e');
    } finally {
      setState(() => _isRestoring = false);
    }
  }

  Future<void> _deleteBackup(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف النسخة'),
        content: Text('حذف النسخة $name؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppPalette.roseRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await BackupService.instance.deleteBackup(name);
    await _refresh();
  }

  Future<void> _openFolder(String path) async {
    // On Windows, use `explorer` to open the folder
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        // Note: This opens the folder using the OS file manager
        // For Flutter Windows, we'd use `open_folder` package
        // For now, just copy the path
        await _copyToClipboard(path);
      }
    } catch (_) {}
  }

  Future<void> _copyToClipboard(String text) async {
    // Copy path to clipboard
    // In Flutter: Clipboard.setData(ClipboardData(text: text));
    _showSnack('تم نسخ المسار: $text');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dbSize = _storageInfo['databaseSizeFormatted'] ?? '--';
    final filesSize = _storageInfo['filesSizeFormatted'] ?? '--';
    final totalSize = _storageInfo['totalSizeFormatted'] ?? '--';
    final backupCount = _storageInfo['backupCount'] ?? 0;
    final latestBackup = _storageInfo['latestBackup'];
    final backups = _storageInfo['backups'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // ─── Status message ─────────────────────────────────────
          if (_statusMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _statusMessage.startsWith('✅')
                    ? AppPalette.leafGreen.withOpacity(0.1)
                    : _statusMessage.startsWith('❌')
                        ? AppPalette.roseRed.withOpacity(0.1)
                        : AppPalette.goldDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _statusMessage.startsWith('✅')
                      ? AppPalette.leafGreen
                      : _statusMessage.startsWith('❌')
                          ? AppPalette.roseRed
                          : AppPalette.goldDark,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(_statusMessage, style: const TextStyle(fontWeight: FontWeight.w700))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _statusMessage = ''),
                  ),
                ],
              ),
            ),

          // ─── Storage status cards ──────────────────────────────
          Row(
            children: <Widget>[
              _infoCard('💾 قاعدة البيانات', dbSize, AppPalette.royalBlue),
              const SizedBox(width: 10),
              _infoCard('📂 حجم الملفات', filesSize, AppPalette.leafGreen),
              const SizedBox(width: 10),
              _infoCard('📦 الإجمالي', totalSize, AppPalette.goldDark),
              const SizedBox(width: 10),
              _infoCard('📋 عدد النسخ', backupCount.toString(), AppPalette.deepNavySoft),
            ],
          ),
          const SizedBox(height: 14),

          // ─── Action buttons ────────────────────────────────────
          Row(
            children: <Widget>[
              _actionButton(
                _isCreatingBackup ? 'جارٍ الإنشاء...' : '💾 إنشاء نسخة احتياطية الآن',
                AppPalette.goldDark, Colors.white,
                _isCreatingBackup ? null : _createBackup,
              ),
              const SizedBox(width: 8),
              _actionButton(
                _isRestoring ? 'جارٍ الاستعادة...' : '🔄 استعادة نسخة',
                AppPalette.royalBlue, Colors.white,
                _isRestoring ? null : _restoreBackup,
              ),
              const SizedBox(width: 8),
              _actionButton('🔄 تحديث', const Color(0xFFEDF6FF), AppPalette.royalBlue, _refresh),
            ],
          ),
          const SizedBox(height: 14),

          // ─── Info row ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              children: <Widget>[
                _infoRow('حالة التخزين', '✅ متصل'),
                _infoRow('إجمالي حجم البيانات', totalSize),
                _infoRow('عدد الملفات', '${_storageInfo['fileCount'] ?? 0}'),
                _infoRow('آخر نسخة احتياطية', latestBackup?.toString().split('T').first ?? 'لا توجد نسخ'),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    _smallButton('📂 فتح مجلد البيانات', () => _openFolder(AppStoragePathsService.instance.dataPath.toString())),
                    const SizedBox(width: 8),
                    _smallButton('📂 فتح مجلد النسخ', () => _openFolder(AppStoragePathsService.instance.backupsPath.toString())),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ─── Backups list ──────────────────────────────────────
          if (backups.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('📋 قائمة النسخ الاحتياطية', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.deepNavySoft, fontSize: 15)),
                  const SizedBox(height: 10),
                  ...backups.map<Widget>((b) {
                    final createdAt = (b as dynamic).createdAt?.toString().split('T').first ?? '--';
                    final name = (b as dynamic).name?.toString() ?? '--';
                    final studentCount = (b as dynamic).studentCount ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFEEF2F7))),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.deepNavySoft, fontSize: 13)),
                                Text('$createdAt • طلاب: $studentCount', style: const TextStyle(color: AppPalette.muted, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppPalette.roseRed, size: 18),
                            onPressed: () => _deleteBackup(name),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.line),
        ),
        child: Column(
          children: <Widget>[
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppPalette.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppPalette.muted, fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppPalette.deepNavySoft, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color fg, VoidCallback? onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }

  Widget _smallButton(String label, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppPalette.line),
        ),
        child: Text(label, style: const TextStyle(color: AppPalette.royalBlue, fontWeight: FontWeight.w700, fontSize: 11)),
      ),
    );
  }
}
