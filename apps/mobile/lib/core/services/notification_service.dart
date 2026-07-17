import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Log the background message
  debugPrint("Handling a background message: ${message.messageId}");

  // Display a local notification (UI-related code should be avoided in the background)
  await NotificationService.showLocalNotification(
    title: message.notification?.title ??
        message.data['title'] ??
        'Emergency SOS Alert',
    body: message.notification?.body ??
        message.data['body'] ??
        'A member of your circle triggered an SOS!',
    payload: message.data.toString(), // Convert payload to string
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
  static bool _initialized = false;
  static bool _localNotificationsInitialized = false;

  static Stream<RemoteMessage> get foregroundMessages =>
      _messageController.stream;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions for notifications
    final fcmAllowed = await _requestFcmPermission();
    final localAllowed = await _requestLocalNotificationPermission();

    if (fcmAllowed || localAllowed) {
      await _registerDeviceToken();
    }

    // Set foreground notification presentation options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    await initializeLocalNotifications();

    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((message) {
      _messageController.add(message);
      unawaited(showLocalNotification(
        title: message.notification?.title ??
            message.data['title'] ??
            'Emergency SOS Alert',
        body: message.notification?.body ??
            message.data['body'] ??
            'A member of your circle triggered an SOS!',
        payload: message.data.toString(),
      ));
    });
  }

  /// Initialize local notifications
  static Future<void> initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;
    _localNotificationsInitialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    // Create notification channel for Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
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

  /// Request FCM notification permissions
  static Future<bool> _requestFcmPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<bool> _requestLocalNotificationPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await _localNotifications
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    if (Platform.isAndroid) {
      return await _localNotifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }

    return true;
  }

  static Future<bool> requestPermissionsAndRegisterDevice() async {
    await initializeLocalNotifications();
    final fcmAllowed = await _requestFcmPermission();
    final localAllowed = await _requestLocalNotificationPermission();
    if (fcmAllowed || localAllowed) {
      await registerDeviceToken();
      return true;
    }
    return false;
  }

  static Future<void> registerDeviceToken() async {
    await _registerDeviceToken();
  }

  /// Register the device token with the backend
  static Future<void> _registerDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint("FCM Token: $token");
        await _uploadTokenToBackend(token);
      }
    } catch (e) {
      debugPrint("Error registering device token: $e");
    }
  }

  /// Upload the FCM token to the backend
  static Future<void> _uploadTokenToBackend(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await ApiService.registerDevice(token, platform);
    } catch (e) {
      debugPrint("Failed to upload token: $e");
    }
  }

  /// Show a local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Handle notification response
  static void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint("Notification payload: $payload");
      // Handle navigation or other actions based on the payload
    }
  }
}
