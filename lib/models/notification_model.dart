class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.targetPage,
    this.targetId,
    required this.createdAt,
    this.isRead = false,
    this.roles = const [],
  });

  final String id;
  final String type; // 'info', 'warning', 'success', 'error'
  final String title;
  final String body;
  final String? targetPage;
  final String? targetId;
  final String createdAt;
  final bool isRead;
  final List<String> roles;

  NotificationItem copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? targetPage,
    String? targetId,
    String? createdAt,
    bool? isRead,
    List<String>? roles,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      targetPage: targetPage ?? this.targetPage,
      targetId: targetId ?? this.targetId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      roles: roles ?? this.roles,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'targetPage': targetPage,
        'targetId': targetId,
        'createdAt': createdAt,
        'isRead': isRead,
        'roles': roles,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? 'info',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        targetPage: json['targetPage']?.toString(),
        targetId: json['targetId']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
        isRead: json['isRead'] == true,
        roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );

  String get timeAgo {
    final now = DateTime.now();
    final created = DateTime.tryParse(createdAt) ?? now;
    final diff = now.difference(created);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return createdAt.split('T').first;
  }
}
