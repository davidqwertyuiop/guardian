import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/features/notifications/data/models/app_notification.dart';
import 'package:guardian/features/notifications/data/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required this.repository})
    : super(const NotificationState()) {
    on<NotificationsStarted>(_onLoad);
    on<NotificationsRefreshRequested>(_onLoad);
    on<NotificationReceived>(_onLoad);
    on<NotificationOpened>(_onOpen);
    on<NotificationOpenHandled>(_onOpenHandled);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
    _pushSubscription = NotificationService.foregroundMessages.listen((_) {
      add(const NotificationReceived());
    });
  }

  final NotificationRepository repository;
  StreamSubscription? _pushSubscription;

  Future<void> _onLoad(
    NotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final snapshot = await repository.fetchNotifications();
      emit(
        state.copyWith(
          isLoading: false,
          items: snapshot.items,
          unreadCount: snapshot.unreadCount,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onOpen(
    NotificationOpened event,
    Emitter<NotificationState> emit,
  ) async {
    if (!event.notification.isRead) {
      await repository.markRead(event.notification.id);
    }
    final items = state.items
        .map(
          (item) => item.id == event.notification.id
              ? item.copyWith(isRead: true)
              : item,
        )
        .toList();
    emit(
      state.copyWith(
        items: items,
        unreadCount: items.where((item) => !item.isRead).length,
        pendingOpen: event.notification.copyWith(isRead: true),
      ),
    );
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAllRead();
    emit(
      state.copyWith(
        unreadCount: 0,
        items: state.items.map((item) => item.copyWith(isRead: true)).toList(),
      ),
    );
  }

  void _onOpenHandled(
    NotificationOpenHandled event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(pendingOpen: null));
  }

  @override
  Future<void> close() {
    _pushSubscription?.cancel();
    return super.close();
  }
}
