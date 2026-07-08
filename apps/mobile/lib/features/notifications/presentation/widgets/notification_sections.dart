import 'package:flutter/material.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'notification_tile.dart';

class NotificationSections extends StatelessWidget {
  const NotificationSections({
    super.key,
    required this.items,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<AppNotification> items;
  final ValueChanged<AppNotification> onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final groups = _group(items);
    return ListView(
      padding: padding,
      children: [
        for (final entry in groups.entries) ...[
          if (entry.value.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ),
            ...entry.value.map(
              (item) => NotificationTile(
                notification: item,
                onTap: () => onTap(item),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

Map<String, List<AppNotification>> _group(List<AppNotification> items) {
  final now = DateTime.now();
  final today = <AppNotification>[];
  final yesterday = <AppNotification>[];
  final older = <AppNotification>[];
  for (final item in items) {
    final local = item.createdAt.toLocal();
    final ageDays = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(local.year, local.month, local.day)).inDays;
    if (ageDays <= 0) {
      today.add(item);
    } else if (ageDays == 1) {
      yesterday.add(item);
    } else {
      older.add(item);
    }
  }
  return {'Today': today, 'Yesterday': yesterday, 'Older': older};
}
