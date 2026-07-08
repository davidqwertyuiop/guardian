part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.pendingOpen,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final bool isLoading;
  final AppNotification? pendingOpen;

  List<AppNotification> get previewItems =>
      items.length > 8 ? items.take(8).toList() : items;

  NotificationState copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    bool? isLoading,
    Object? pendingOpen = _sentinel,
  }) {
    return NotificationState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      pendingOpen: identical(pendingOpen, _sentinel)
          ? this.pendingOpen
          : pendingOpen as AppNotification?,
    );
  }

  @override
  List<Object?> get props => [items, unreadCount, isLoading, pendingOpen];
}

const _sentinel = Object();
