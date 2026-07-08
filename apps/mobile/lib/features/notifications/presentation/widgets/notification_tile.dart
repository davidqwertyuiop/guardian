import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _palette(
      notification.kind,
      theme.brightness == Brightness.dark,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 10),
              child: Icon(
                Icons.circle,
                size: 8,
                color: notification.isRead ? Colors.grey.shade400 : colors.$1,
              ),
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.$2,
              backgroundImage: notification.actorAvatarUrl?.isNotEmpty == true
                  ? NetworkImage(notification.actorAvatarUrl!)
                  : null,
              child: notification.actorAvatarUrl?.isNotEmpty == true
                  ? null
                  : Icon(colors.$3, color: colors.$1, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.25,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.78,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat(
                      'h:mm a',
                    ).format(notification.createdAt.toLocal()),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.$2,
                shape: BoxShape.circle,
              ),
              child: Icon(colors.$4, color: colors.$1, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

(Color, Color, IconData, IconData) _palette(String kind, bool isDark) {
  if (kind.startsWith('sos')) {
    return (
      const Color(0xFFFF3B7A),
      const Color(0xFFFF3B7A).withValues(alpha: isDark ? 0.22 : 0.12),
      Icons.sos_rounded,
      kind == 'sos_cancelled'
          ? Icons.check_rounded
          : Icons.priority_high_rounded,
    );
  }
  if (kind.startsWith('journey')) {
    return (
      const Color(0xFF22C55E),
      const Color(0xFF22C55E).withValues(alpha: isDark ? 0.22 : 0.12),
      Icons.route_rounded,
      kind == 'journey_stopped'
          ? Icons.check_circle_rounded
          : Icons.navigation_rounded,
    );
  }
  return (
    const Color(0xFF7C60FF),
    const Color(0xFF7C60FF).withValues(alpha: isDark ? 0.22 : 0.12),
    Icons.notifications_rounded,
    Icons.circle_notifications_rounded,
  );
}
