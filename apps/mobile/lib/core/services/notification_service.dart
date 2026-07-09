import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
  NotificationService.showLocalNotification(
    title:
        message.notification?.title ??
        message.data['title'] ??
        'Emergency SOS Alert',
    body:
        message.notification?.body ??
        message.data['body'] ??
        'A member of your circle triggered an SOS!',
    payload: Map<String, String>.from(message.data),
  );
}

class NotificationService {
  static final _messageController = StreamController<RemoteMessage>.broadcast();
  static bool _tokenRefreshListenerAttached = false;

  static Stream<RemoteMessage> get foregroundMessages =>
      _messageController.stream;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 1. Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      // We use null to fall back to default launcher icon
      null,
      [
        NotificationChannel(
          channelKey: 'guardian_sos',
          channelName: 'Emergency SOS Alerts',
          channelDescription:
              'High-priority notifications for emergency SOS broadcasts.',
          defaultColor: const Color(0xFFFF3B30),
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          defaultPrivacy: NotificationPrivacy.Public,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([
            0,
            1000,
            500,
            1000,
            500,
            1000,
            500,
            1000,
          ]),
        ),
      ],
      debug: true,
    );

    // 2. Request local notification permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // 3. Register FCM foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Received a foreground message: ${message.messageId}");
      _messageController.add(message);
      showLocalNotification(
        title:
            message.notification?.title ??
            message.data['title'] ??
            'Emergency SOS Alert',
        body:
            message.notification?.body ??
            message.data['body'] ??
            'A member of your circle triggered an SOS!',
        payload: Map<String, String>.from(message.data),
      );
    });

    // 4. Handle action when user taps on the notification
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  /// Called when user taps a notification (foreground, background, or terminated)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint("Notification action received: ${receivedAction.id}");
    // Here we can navigate to the Live Map or details screen.
    // Standard approach: publish to a stream or navigate via GlobalKey navigator.
  }

  /// Request permissions for FCM and upload device token to our backend
  static Future<void> registerDeviceToken() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: Platform.isIOS,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint(
          "Notification permission denied; skipping FCM token upload.",
        );
        return;
      }

      final token = await _getReadyFcmToken();
      if (token == null) {
        debugPrint("FCM token is not ready yet; skipping upload for now.");
        return;
      }

      debugPrint("FCM Registration Token: $token");
      final platform = Platform.isIOS ? 'ios' : 'android';
      await ApiService.registerDevice(token, platform);

      if (!_tokenRefreshListenerAttached) {
        _tokenRefreshListenerAttached = true;
        FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
          debugPrint("FCM Registration Token Refreshed: $token");
          final platform = Platform.isIOS ? 'ios' : 'android';
          await ApiService.registerDevice(token, platform);
        });
      }
    } catch (e) {
      debugPrint("Error registering FCM token: $e");
    }
  }

  static Future<String?> _getReadyFcmToken() async {
    if (Platform.isIOS) {
      for (var attempt = 0; attempt < 5; attempt++) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }
    return FirebaseMessaging.instance.getToken();
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
