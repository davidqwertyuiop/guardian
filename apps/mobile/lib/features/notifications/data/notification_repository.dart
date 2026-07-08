import 'package:guardian/core/services/api_service.dart';
import 'models/app_notification.dart';

class NotificationRepository {
  Future<NotificationSnapshot> fetchNotifications({int limit = 50}) async {
    final json = await ApiService.getNotifications(limit: limit);
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
    return NotificationSnapshot(
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }

  Future<void> markRead(String id) => ApiService.markNotificationRead(id);

  Future<void> markAllRead() => ApiService.markAllNotificationsRead();
}

class NotificationSnapshot {
  const NotificationSnapshot({required this.unreadCount, required this.items});

  final int unreadCount;
  final List<AppNotification> items;
}
