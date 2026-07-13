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

  bool _matchesStudent(NotificationItem n, String sid) {
    return n.targetId == sid || n.meta['studentId'] == sid;
  }

  bool _isDueNotification(NotificationItem n) {
    if (n.category == 'installment_due') return true;
    if (n.category == 'installment_paid') return false;
    return n.type == 'warning' && (n.title.contains('مستحق') || n.body.contains('مستحق'));
  }

  /// Mark installment-due notifications for a student as paid (green).
  /// Ensures the yellow due state never remains after payment.
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
      if (!_matchesStudent(n, sid)) continue;
      if (!_isDueNotification(n) && n.category != 'installment_due') {
        // still convert any leftover yellow due-like item for this student
        if (!(n.type == 'warning' && n.title.contains(studentName))) continue;
      }
      if (n.category == 'installment_paid' && n.type == 'success') continue;
      if (!_isDueNotification(n) && n.category != 'installment_due' && !(n.type == 'warning')) {
        continue;
      }
      _notifications[i] = n.copyWith(
        type: 'success',
        title: 'تم الدفع — $studentName',
        body: 'تم دفع قسط/دفعة للطالب $studentName بقيمة ${amount.toStringAsFixed(0)} $currency بتاريخ $date. يمكن للإدارة حذف الإشعار أو أرشفته.',
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
    // remove any remaining pure yellow due items that failed conversion edge cases
    final before = _notifications.length;
    _notifications.removeWhere((n) => _matchesStudent(n, sid) && _isDueNotification(n) && n.category != 'installment_paid');
    if (_notifications.length != before) changed = true;

    if (!changed) {
      await addSimple(
        type: 'success',
        title: 'تم الدفع — $studentName',
        body: 'تم دفع قسط/دفعة للطالب $studentName بقيمة ${amount.toStringAsFixed(0)} $currency بتاريخ $date. يمكن للإدارة حذف الإشعار أو أرشفته.',
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
    // never re-create yellow if a paid notice exists for this student
    final hasPaid = _notifications.any((n) =>
        !n.isArchived &&
        n.category == 'installment_paid' &&
        _matchesStudent(n, sid));
    if (hasPaid) return;
    final exists = _notifications.any((n) =>
        !n.isArchived &&
        n.category == 'installment_due' &&
        _matchesStudent(n, sid));
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

  /// Convert/remove yellow due notices for students who are no longer overdue.
  Future<void> clearDueForStudentsNotIn(Set<int> overdueStudentIds) async {
    var changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if (!_isDueNotification(n) && n.category != 'installment_due') continue;
      final sid = n.meta['studentId'] ?? n.targetId ?? '';
      final id = int.tryParse(sid) ?? -1;
      if (id > 0 && overdueStudentIds.contains(id)) continue;
      // student paid / not overdue anymore -> turn green summary or drop yellow
      final name = n.meta['studentName'] ?? n.title.replaceFirst('مستحق — ', '');
      _notifications[i] = n.copyWith(
        type: 'success',
        title: 'تم الدفع — $name',
        body: 'لم يعد هذا الطالب ضمن المستحقات الحالية. يمكن للإدارة حذف الإشعار أو أرشفته.',
        category: 'installment_paid',
        isRead: n.isRead,
        isArchived: false,
        meta: {
          ...n.meta,
          'status': 'paid',
        },
      );
      changed = true;
    }
    if (changed) await _persist();
  }

  Future<void> _persist() async {
    await SchoolDatabaseService.instance.saveJson(
      'notifications',
      _notifications.map((n) => n.toJson()).toList(),
    );
  }
}
