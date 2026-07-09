import 'package:flutter/material.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'notification_tile_palette.dart';

class NotificationTileAvatar extends StatelessWidget {
  const NotificationTileAvatar({
    super.key,
    required this.notification,
    required this.palette,
  });

  final AppNotification notification;
  final NotificationTilePalette palette;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: palette.soft,
      backgroundImage: notification.actorAvatarUrl?.isNotEmpty == true
          ? NetworkImage(notification.actorAvatarUrl!)
          : null,
      child: notification.actorAvatarUrl?.isNotEmpty == true
          ? null
          : Icon(palette.leadingIcon, color: palette.accent, size: 20),
    );
  }
}
