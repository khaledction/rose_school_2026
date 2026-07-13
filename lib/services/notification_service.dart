import 'dart:convert';

import '../models/notification_model.dart';
import 'school_database_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final List<NotificationItem> _notifications = [];
  bool _initialized = false;

  List<NotificationItem> get all => List<NotificationItem>.unmodifiable(_notifications);

  List<NotificationItem> get active => _notifications.where((n) => !n.isArchived).toList();

  List<NotificationItem> get archived => _notifications.where((n) => n.isArchived).toList();

  List<NotificationItem> get unread => _notifications.where((n) => !n.isRead && !n.isArchived).toList();

  int get unreadCount => _notifications.where((n) => !n.isRead && !n.isArchived).length;

  List<NotificationItem> forRoles(List<String> roles, {bool includeArchived = false}) {
    final source = includeArchived ? all : active;
    if (roles.isEmpty) return source;
    return source.where((n) => n.roles.isEmpty || n.roles.any((r) => roles.contains(r))).toList();
  }

  Future<void> init() async {
    if (_initialized) return;
    final json = await SchoolDatabaseService.instance.readJson('notifications');
    if (json != null) {
      final list = jsonDecode(json) as List<dynamic>;
      _notifications.addAll(list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)));
    }
    _initialized = true;
  }

  Future<void> add(NotificationItem notification) async {
    _notifications.insert(0, notification);
    await _persist();
  }

  Future<void> addSimple({
    required String type,
    required String title,
    required String body,
    String? targetPage,
    String? targetId,
    List<String> roles = const [],
    String category = '',
    Map<String, String> meta = const {},
  }) async {
    await add(NotificationItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      targetPage: targetPage,
      targetId: targetId,
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
      isArchived: false,
      roles: roles,
      category: category,
      meta: meta,
    ));
  }

  Future<void> update(NotificationItem notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index < 0) return;
    _notifications[index] = notification;
    await _persist();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _persist();
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isArchived) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _persist();
  }

  Future<void> archive(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _notifications[index] = _notifications[index].copyWith(isArchived: true, isRead: true);
    await _persist();
  }

  Future<void> unarchive(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _notifications[index] = _notifications[index].copyWith(isArchived: false);
    await _persist();
  }

  Future<void> remove(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _persist();
  }

  Future<void> clear() async {
    _notifications.clear();
    await _persist();
  }

  /// Mark installment-due notifications for a student as paid (green).
  Future<void> markInstallmentPaidForStudent({
    required int studentId,
    required String studentName,
    required double amount,
    required String currency,
    required String date,
  }) async {
    final sid = studentId.toString();
    var changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      final isDue = n.category == 'installment_due' ||
          (n.targetId == sid && (n.title.contains('مستحق') || n.body.contains('مستحق')));
      if (!isDue) continue;
      if (n.targetId != null && n.targetId != sid && n.meta['studentId'] != sid) continue;
      _notifications[i] = n.copyWith(
        type: 'success',
        title: 'تم الدفع — $studentName',
        body: 'تم دفع قسط/دفعة للطالب $studentName بقيمة ${amount.toStringAsFixed(0)} $currency بتاريخ $date.',
        category: 'installment_paid',
        isRead: false,
        isArchived: false,
        meta: {
          ...n.meta,
          'studentId': sid,
          'studentName': studentName,
          'amount': amount.toStringAsFixed(0),
          'currency': currency,
          'date': date,
          'status': 'paid',
        },
      );
      changed = true;
    }
    if (!changed) {
      await addSimple(
        type: 'success',
        title: 'تم الدفع — $studentName',
        body: 'تم دفع قسط/دفعة للطالب $studentName بقيمة ${amount.toStringAsFixed(0)} $currency بتاريخ $date.',
        targetPage: 'accounting',
        targetId: sid,
        roles: const ['الإدارة'],
        category: 'installment_paid',
        meta: {
          'studentId': sid,
          'studentName': studentName,
          'amount': amount.toStringAsFixed(0),
          'currency': currency,
          'date': date,
          'status': 'paid',
        },
      );
      return;
    }
    await _persist();
  }

  Future<void> ensureInstallmentDueNotification({
    required int studentId,
    required String studentName,
    required String gradeLabel,
  }) async {
    final sid = studentId.toString();
    final exists = _notifications.any((n) =>
        !n.isArchived &&
        n.category == 'installment_due' &&
        (n.targetId == sid || n.meta['studentId'] == sid));
    if (exists) return;
    await addSimple(
      type: 'warning',
      title: 'مستحق — $studentName',
      body: 'الطالب $studentName ($gradeLabel) لم يُسدّد قسط هذا الشهر بعد انتهاء نافذة الدفع (1–5).',
      targetPage: 'accounting',
      targetId: sid,
      roles: const ['الإدارة'],
      category: 'installment_due',
      meta: {
        'studentId': sid,
        'studentName': studentName,
        'status': 'due',
      },
    );
  }

  Future<void> _persist() async {
    await SchoolDatabaseService.instance.saveJson(
      'notifications',
      _notifications.map((n) => n.toJson()).toList(),
    );
  }
}
