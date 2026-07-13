import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeLocalNotifications();
  debugPrint("Handling a background message: ${message.messageId}");
  await NotificationService.showLocalNotification(
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
  static const _channelId = 'guardian_sos';
  static const _channelName = 'Emergency SOS Alerts';
  static const _channelDescription =
      'High-priority notifications for emergency SOS broadcasts.';

  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _messageController = StreamController<RemoteMessage>.broadcast();
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  static bool _tokenRefreshListenerAttached = false;
  static bool _initialized = false;
  static bool _localNotificationsInitialized = false;

  static Stream<RemoteMessage> get foregroundMessages =>
      _messageController.stream;

  /// Initializes local notifications for foreground and offline/device-local
  /// alerts. This is intentionally separate from Firebase Messaging.
  static Future<void> initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;
    _localNotificationsInitialized = true;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          'guardian_sos',
          actions: [
            DarwinNotificationAction.plain('OPEN_APP', 'Open Guardian'),
            DarwinNotificationAction.plain('CALL', 'Call'),
          ],
        ),
      ],
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    // 1. Initialize local notifications without prompting for permission.
    await initializeLocalNotifications();

    // 2. Register FCM foreground message handler without requesting permission.
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      debugPrint("Received a foreground message: ${message.messageId}");
      _messageController.add(message);
      unawaited(showLocalNotification(
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
      ));
    });
  }

  /// Called when user taps a notification (foreground, background, or terminated)
  @pragma("vm:entry-point")
  static Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    debugPrint("Notification action received: ${response.id}");
    if (response.actionId == 'CALL') {
      final phone = _payloadMap(response.payload)['phone'];
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

    final localAllowed = await _requestLocalNotificationPermission();

    if (fcmAllowed || localAllowed) {
      await registerDeviceToken();
      return true;
    }
    return false;
  }

  static Future<bool> _requestLocalNotificationPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await _localNotifications
              .resolvePlatformSpecificImplementation<
                DarwinFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    if (Platform.isAndroid) {
      return await _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;
    }

    return true;
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

    final actions = <AndroidNotificationAction>[];
    final androidStyle = _androidStyleForType(type, body);
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'guardian_sos',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    if (type == 'sos') {
      final name = payload?['name'] ?? 'Temi';
      actions.addAll([
        const AndroidNotificationAction(
          'OPEN_APP',
          'Open Guardian',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'CALL',
          'Call $name',
          showsUserInterface: true,
        ),
      ]);
    }

    await initializeLocalNotifications();
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: false,
          visibility: NotificationVisibility.public,
          playSound: true,
          enableVibration: true,
          actions: actions,
          styleInformation: androidStyle,
        ),
        iOS: iosDetails,
      ),
      payload: _encodePayload(payload),
    );
  }

  static StyleInformation? _androidStyleForType(String? type, String body) {
    if (type != 'journey_completed' &&
        type != 'journey_started' &&
        type != 'testing_rich') {
      return null;
    }

    return BigTextStyleInformation(body);
  }

  static String? _encodePayload(Map<String, String>? payload) {
    if (payload == null || payload.isEmpty) return null;
    return payload.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  static Map<String, String> _payloadMap(String? payload) {
    if (payload == null || payload.isEmpty) return const {};
    return Map.fromEntries(
      payload.split('&').where((part) => part.contains('=')).map((part) {
        final separator = part.indexOf('=');
        return MapEntry(
          Uri.decodeComponent(part.substring(0, separator)),
          Uri.decodeComponent(part.substring(separator + 1)),
        );
      }),
    );
  }
}
