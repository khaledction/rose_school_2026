import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../models/notification_model.dart';
import '../services/app_storage_paths_service.dart';
import '../services/notification_service.dart';
import '../theme/app_palette.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.studentCount,
    required this.studentMaleCount,
    required this.studentFemaleCount,
    required this.employeeCount,
    required this.userCount,
    required this.totalIncome,
    required this.totalExpenses,
    required this.onNavigate,
    required this.onRefresh,
  });

  final int studentCount;
  final int studentMaleCount;
  final int studentFemaleCount;
  final int employeeCount;
  final int userCount;
  final double totalIncome;
  final double totalExpenses;
  final void Function(String pageId, {String? targetId}) onNavigate;
  final VoidCallback onRefresh;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _storageStatus = 'جارٍ التحميل...';
  int _backupCount = 0;
  String _lastBackup = 'غير معروف';
  String _dbSize = '...';

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    try {
      final paths = AppStoragePathsService.instance;
      final dbPath = await paths.databasePath;
      final dbFile = File(dbPath);
      final dbSize = await dbFile.exists() ? dbFile.lengthSync() : 0;

      final backupsDir = await paths.backupsDir;
      final backups = <FileSystemEntity>[];
      await for (final entity in backupsDir.list()) {
        if (entity is File && p.extension(entity.path).toLowerCase() == '.zip') {
          backups.add(entity);
        }
      }
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      if (mounted) {
        setState(() {
          _dbSize = _formatBytes(dbSize);
          _backupCount = backups.length;
          _lastBackup = backups.isNotEmpty
              ? backups.first.statSync().modified.toIso8601String().split('T').first
              : 'لا توجد نسخ';
          _storageStatus = '✅ متصل';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _storageStatus = '⚠️ خطأ في القراءة');
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final netIncome = widget.totalIncome - widget.totalExpenses;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // ─── First row: key metrics ─────────────────────────────
          _buildMetricsRow(netIncome),
          const SizedBox(height: 14),

          // ─── Second row: detailed cards ─────────────────────────
          Row(
            children: <Widget>[
              Expanded(child: _buildStorageCard()),
              const SizedBox(width: 14),
              Expanded(child: _buildNotificationsCard()),
            ],
          ),
          const SizedBox(height: 14),

          // ─── Third row: (removed)
        ],
      ),
    );
  }

  Widget _buildMetricsRow(double netIncome) {
    return SizedBox(
      height: 120,
      child: Row(
        children: <Widget>[
          _metricTile('👥 الطلاب', widget.studentCount.toString(), AppPalette.royalBlue, null,
              subtitle: '♂ ${widget.studentMaleCount}  ♀ ${widget.studentFemaleCount}'),
          const SizedBox(width: 10),
          _metricTile('👤 الموظفين', widget.employeeCount.toString(), AppPalette.leafGreen, null),
          const SizedBox(width: 10),
          _metricTile('👮 المستخدمين', widget.userCount.toString(), AppPalette.goldDark, null),
          const SizedBox(width: 10),
          _metricTile(
            '💰 صافي الشهر',
            '${netIncome.toStringAsFixed(0)} ل.س',
            netIncome >= 0 ? AppPalette.leafGreen : AppPalette.roseRed,
            null,
            subtitle: 'وارد: ${widget.totalIncome.toStringAsFixed(0)}  صادر: ${widget.totalExpenses.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color, IconData? icon, {String? subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.line),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.06), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label,
                style: const TextStyle(
                    color: AppPalette.muted, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: subtitle == null ? 28 : 22,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppPalette.muted, fontSize: 11, height: 1.3)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.06), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('💾 التخزين المحلي',
                  style: TextStyle(
                      color: AppPalette.deepNavySoft,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              const Spacer(),
              Text(_storageStatus,
                  style: const TextStyle(fontSize: 12, color: AppPalette.leafGreen)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('حجم قاعدة البيانات', _dbSize),
          _infoRow('عدد النسخ الاحتياطية', _backupCount.toString()),
          _infoRow('آخر نسخة احتياطية', _lastBackup),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _actionChip('📂 فتح المجلد', () {
                widget.onNavigate('backup');
              }),
              const SizedBox(width: 8),
              _actionChip('🔄 تحديث', () {
                _loadStorageInfo();
                widget.onRefresh();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    final recent = NotificationService.instance.all.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.06), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🔔 آخر الإشعارات',
                  style: TextStyle(
                      color: AppPalette.deepNavySoft,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              const Spacer(),
              if (NotificationService.instance.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppPalette.roseRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${NotificationService.instance.unreadCount} جديد',
                    style: const TextStyle(
                        color: AppPalette.roseRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('لا توجد إشعارات بعد',
                    style: TextStyle(color: AppPalette.muted)),
              ),
            )
          else
            ...recent.map((notif) => _notificationTile(notif)),
        ],
      ),
    );
  }

  Widget _notificationTile(NotificationItem notif) {
    IconData icon;
    Color color;
    switch (notif.type) {
      case 'success':
        icon = Icons.check_circle;
        color = AppPalette.leafGreen;
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        color = AppPalette.goldDark;
        break;
      case 'error':
        icon = Icons.error;
        color = AppPalette.roseRed;
        break;
      default:
        icon = Icons.info_outline;
        color = AppPalette.royalBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!notif.isRead) {
            NotificationService.instance.markAsRead(notif.id);
          }
          if (notif.targetPage != null) {
            widget.onNavigate(notif.targetPage!, targetId: notif.targetId);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: AppPalette.deepNavySoft,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(notif.timeAgo,
                            style: const TextStyle(
                                color: AppPalette.muted, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(notif.body,
                        style: const TextStyle(
                            color: AppPalette.muted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppPalette.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppPalette.deepNavySoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.line),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(20, 40, 90, 0.06), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('⚡ إجراءات سريعة',
              style: TextStyle(
                  color: AppPalette.deepNavySoft,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _quickActionChip('➕ طالب جديد', Icons.person_add, AppPalette.royalBlue, () {
                widget.onNavigate('form');
              }),
              _quickActionChip('📅 تسجيل حضور', Icons.calendar_today, AppPalette.leafGreen, () {
                widget.onNavigate('attendance');
              }),
              _quickActionChip('💰 إيراد جديد', Icons.account_balance, AppPalette.goldDark, () {
                widget.onNavigate('accounting');
              }),
              _quickActionChip('📋 كشف متأخرات', Icons.warning_amber, AppPalette.roseRed, () {
                widget.onNavigate('accounting');
              }),
              _quickActionChip('💾 نسخة احتياطية', Icons.backup, AppPalette.deepNavySoft, () {
                widget.onNavigate('backup');
              }),
              _quickActionChip('📊 النتائج والمعدلات', Icons.sort, const Color(0xFF1E7A79), () {
                widget.onNavigate('student_sorting');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppPalette.line),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppPalette.royalBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      ),
    );
  }

  Widget _quickActionChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
