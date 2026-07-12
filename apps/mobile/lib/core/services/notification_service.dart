import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Awesome Notifications must be re-initialized in the background isolate
  // because main() never runs here, so channels are not yet registered.
  await NotificationService.initializeAwesomeNotifications();
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
    payload: message.data.map((key, value) => MapEntry(key, value.toString())),
  );
}

class NotificationService {
  static final _messageController = StreamController<RemoteMessage>.broadcast();
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  static bool _tokenRefreshListenerAttached = false;
  static bool _initialized = false;

  static Stream<RemoteMessage> get foregroundMessages =>
      _messageController.stream;

  /// Initializes the Awesome Notifications channel definitions.
  /// Must be called from BOTH main() and the background isolate handler,
  /// because the background isolate runs without executing main().
  static Future<void> initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      // null = fall back to the default launcher icon
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
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 1. Initialize Awesome Notifications channels
    await initializeAwesomeNotifications();

    // 2. Register FCM foreground message handler without requesting permission.
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
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
        payload: message.data.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    });

    // 3. Handle action when user taps on the notification
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
    if (receivedAction.buttonKeyPressed == 'CALL') {
      final phone = receivedAction.payload?['phone'];
      if (phone != null && phone.isNotEmpty) {
        final Uri telUri = Uri.parse('tel:$phone');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      }
    }
  }

  static Future<bool> requestPermissionsAndRegisterDevice() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      // Critical Alerts require a separate Apple entitlement. Requesting them
      // in a normal build can fail on physical iOS devices during Home startup.
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final fcmAllowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    var localAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!localAllowed) {
      localAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }

    if (fcmAllowed || localAllowed) {
      await registerDeviceToken();
      return true;
    }
    return false;
  }

  /// Request permissions for FCM and upload device token to our backend
  static Future<void> registerDeviceToken() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint(
          "Notification permission is not granted; skipping FCM token upload.",
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
    final type = payload?['type'];

    List<NotificationActionButton>? actionButtons;
    String? largeIcon;
    String? bigPicture;
    NotificationLayout layout = NotificationLayout.Default;

    if (type == 'sos') {
      final name = payload?['name'] ?? 'Temi';
      actionButtons = [
        NotificationActionButton(
          key: 'OPEN_APP',
          label: 'Open Guardian',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'CALL',
          label: 'Call $name',
          actionType: ActionType.Default,
        ),
      ];
    } else if (type == 'journey_completed') {
      largeIcon = 'asset://assets/images/notification_map_route.png';
      bigPicture = 'asset://assets/images/notification_map_route.png';
      layout = NotificationLayout.BigPicture;
    } else if (type == 'journey_started') {
      largeIcon = 'asset://assets/images/notification_gradient_map.png';
      bigPicture = 'asset://assets/images/notification_gradient_map.png';
      layout = NotificationLayout.BigPicture;
    } else if (type == 'testing_rich') {
      bigPicture = 'asset://assets/images/notification_gradient_map.png';
      layout = NotificationLayout.BigPicture;
      actionButtons = [
        NotificationActionButton(
          key: 'SHARE',
          label: 'Share',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'DELETE',
          label: 'Delete',
          actionType: ActionType.Default,
        ),
      ];
    }

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
        largeIcon: largeIcon,
        bigPicture: bigPicture,
        notificationLayout: layout,
      ),
      actionButtons: actionButtons,
    );
  }
}
