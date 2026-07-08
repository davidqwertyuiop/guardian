import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';
import 'notification_sections.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.onNotificationTap});

  final ValueChanged<AppNotification>? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationBloc>().add(
              const NotificationsMarkAllReadRequested(),
            ),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 12),
              _UnreadPill(count: state.unreadCount),
              const SizedBox(height: 8),
              Expanded(
                child: NotificationSections(
                  items: state.items,
                  onTap: (item) {
                    Navigator.of(context).pop();
                    if (onNotificationTap != null) {
                      onNotificationTap!(item);
                    } else {
                      context.read<NotificationBloc>().add(
                        NotificationOpened(item),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UnreadPill extends StatelessWidget {
  const _UnreadPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count == 0
        ? 'No new notifications'
        : '$count new notifications';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF7C60FF).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: Color(0xFF7C60FF),
        ),
      ),
    );
  }
}
