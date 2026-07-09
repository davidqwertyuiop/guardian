import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';
import 'notification_sections.dart';
import 'notification_unread_pill.dart';
import 'notifications_screen_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.onNotificationTap});

  final ValueChanged<AppNotification>? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return Column(
              children: [
                const NotificationsScreenHeader(),
                const SizedBox(height: 20),
                NotificationUnreadPill(count: state.unreadCount),
                const SizedBox(height: 12),
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
      ),
    );
  }
}
