import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';

class NotificationTileBody extends StatelessWidget {
  const NotificationTileBody({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('h:mm a').format(notification.createdAt.toLocal()),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
            ),
          ),
        ],
      ),
    );
  }
}
