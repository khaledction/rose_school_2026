import 'dart:convert';

import '../models/notification_model.dart';
import 'school_database_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final List<NotificationItem> _notifications = [];
  bool _initialized = false;

  List<NotificationItem> get all => List<NotificationItem>.unmodifiable(_notifications);

  List<NotificationItem> get unread => _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> forRoles(List<String> roles) {
    if (roles.isEmpty) return all;
    return _notifications.where((n) => n.roles.isEmpty || n.roles.any((r) => roles.contains(r))).toList();
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
      roles: roles,
    ));
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _persist();
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
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

  Future<void> _persist() async {
    await SchoolDatabaseService.instance.saveJson(
      'notifications',
      _notifications.map((n) => n.toJson()).toList(),
    );
  }
}
