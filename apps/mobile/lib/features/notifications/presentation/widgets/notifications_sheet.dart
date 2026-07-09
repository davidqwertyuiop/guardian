import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';
import 'notification_sections.dart';
import 'notification_unread_pill.dart';
import 'notifications_sheet_header.dart';
import 'notifications_screen.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key, this.onNotificationTap});

  final ValueChanged<AppNotification>? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.72,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        const NotificationsSheetHeader(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: NotificationUnreadPill(
                              count: state.unreadCount,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: NotificationSections(
                            items: state.previewItems,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        if (state.items.length > state.previewItems.length)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<NotificationBloc>(),
                                    child: NotificationsScreen(
                                      onNotificationTap: onNotificationTap,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Text('View all notifications'),
                          ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
