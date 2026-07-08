part of 'notification_bloc.dart';

sealed class NotificationEvent {
  const NotificationEvent();
}

class NotificationsStarted extends NotificationEvent {
  const NotificationsStarted();
}

class NotificationsRefreshRequested extends NotificationEvent {
  const NotificationsRefreshRequested();
}

class NotificationReceived extends NotificationEvent {
  const NotificationReceived();
}

class NotificationOpened extends NotificationEvent {
  const NotificationOpened(this.notification);
  final AppNotification notification;
}

class NotificationOpenHandled extends NotificationEvent {
  const NotificationOpenHandled();
}

class NotificationsMarkAllReadRequested extends NotificationEvent {
  const NotificationsMarkAllReadRequested();
}
