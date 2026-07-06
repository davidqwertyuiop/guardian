# notification_service.dart

* **File Path:** `apps/mobile/lib/core/services/notification_service.dart`
* **Type:** `DART`

---

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:guardian/core/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background handler,
  // make sure you call Firebase.initializeApp() first.
  debugPrint("Handling a background message: ${message.messageId}");
  NotificationService.showLocalNotification(
    title: message.notification?.title ?? message.data['title'] ?? 'Emergency SOS Alert',
    body: message.notification?.body ?? message.data['body'] ?? 'A member of your circle triggered an SOS!',
    payload: Map<String, String>.from(message.data),
  );
}

class NotificationService {
  static Future<void> initialize() async {
    // 1. Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      // We use null to fall back to default launcher icon
      null,
      [
        NotificationChannel(
          channelKey: 'guardian_sos',
          channelName: 'Emergency SOS Alerts',
          channelDescription: 'High-priority notifications for emergency SOS broadcasts.',
          defaultColor: const Color(0xFFFF3B30),
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultPrivacy: NotificationPrivacy.Public,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
        ),
      ],
      debug: true,
    );

    // 2. Request local notification permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // 3. Register FCM background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Register FCM foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Received a foreground message: ${message.messageId}");
      showLocalNotification(
        title: message.notification?.title ?? message.data['title'] ?? 'Emergency SOS Alert',
        body: message.notification?.body ?? message.data['body'] ?? 'A member of your circle triggered an SOS!',
        payload: Map<String, String>.from(message.data),
      );
    });

    // 5. Handle action when user taps on the notification
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  /// Called when user taps a notification (foreground, background, or terminated)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint("Notification action received: ${receivedAction.id}");
    // Here we can navigate to the Live Map or details screen.
    // Standard approach: publish to a stream or navigate via GlobalKey navigator.
  }

  /// Request permissions for FCM and upload device token to our backend
  static Future<void> registerDeviceToken() async {
    try {
      // 1. Request iOS notification settings
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: true,
          provisional: false,
          sound: true,
        );
      }

      // 2. Retrieve FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint("FCM Registration Token: $token");
        final platform = Platform.isIOS ? 'ios' : 'android';
        await ApiService.registerDevice(token, platform);
      }

      // 3. Listen to token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        debugPrint("FCM Registration Token Refreshed: $token");
        final platform = Platform.isIOS ? 'ios' : 'android';
        await ApiService.registerDevice(token, platform);
      });
    } catch (e) {
      debugPrint("Error registering FCM token: $e");
    }
  }

  /// Display a local HUD notification with maximum sound and alert characteristics
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'guardian_sos',
        title: title,
        body: body,
        category: NotificationCategory.Alarm,
        fullScreenIntent: true,
        wakeUpScreen: true,
        payload: payload,
      ),
    );
  }
}

```
