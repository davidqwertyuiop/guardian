import 'package:flutter/material.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'notification_tile_avatar.dart';
import 'notification_tile_body.dart';
import 'notification_tile_palette.dart';

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
    final palette = notificationTilePalette(
      notification.kind,
      Theme.of(context).brightness == Brightness.dark,
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
                color: notification.isRead
                    ? Colors.grey.shade400
                    : palette.accent,
              ),
            ),
            NotificationTileAvatar(
              notification: notification,
              palette: palette,
            ),
            const SizedBox(width: 12),
            NotificationTileBody(notification: notification),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: palette.soft,
                shape: BoxShape.circle,
              ),
              child: Icon(palette.statusIcon, color: palette.accent, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
