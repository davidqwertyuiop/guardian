import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/core/services/notification_service.dart';

class BackgroundTriggerService {
  static final BackgroundTriggerService _instance =
      BackgroundTriggerService._internal();
  factory BackgroundTriggerService() => _instance;
  BackgroundTriggerService._internal();

  StreamSubscription? _accelerometerSubscription;
  final List<DateTime> _tapTimestamps = [];

  // Acceleration threshold to detect a physical tap/sharp shake on the phone (m/s^2)
  static const double _tapThreshold = 18.0;

  // Debounce time between taps to avoid double-counting a single bounce (ms)
  static const int _debounceMs = 350;

  // Time window to accumulate 5 taps (seconds)
  static const int _timeWindowSeconds = 4;

  DateTime? _lastTapTime;
  bool _isTriggering = false;

  /// Start listening for taps/shakes in the background
  void startListening() {
    if (_accelerometerSubscription != null) return;

    debugPrint(
      "BackgroundTriggerService: Listening for physical SOS tap triggers...",
    );

    _accelerometerSubscription = userAccelerometerEventStream().listen((
      UserAccelerometerEvent event,
    ) {
      final double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _tapThreshold) {
        final now = DateTime.now();

        // Debounce checks
        if (_lastTapTime != null &&
            now.difference(_lastTapTime!).inMilliseconds < _debounceMs) {
          return;
        }

        _lastTapTime = now;
        _registerTap(now);
      }
    });
  }

  /// Stop listening for taps/shakes
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  /// Process a new tap event
  void _registerTap(DateTime time) async {
    // Check if vibration is supported and vibrate shortly to acknowledge the tap
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 80);
    }

    _tapTimestamps.add(time);

    // Remove taps outside the window
    _tapTimestamps.removeWhere(
      (t) => time.difference(t).inSeconds > _timeWindowSeconds,
    );

    debugPrint(
      "BackgroundTriggerService: Tap registered. Count: ${_tapTimestamps.length}",
    );

    if (_tapTimestamps.length >= 5) {
      _tapTimestamps.clear();
      _triggerSos();
    }
  }

  /// Trigger the SOS flow
  void _triggerSos() async {
    if (_isTriggering) return;
    _isTriggering = true;

    debugPrint(
      "BackgroundTriggerService: 5 taps detected! Launching SOS emergency trigger...",
    );

    // Vibrate intensely to warn user SOS has been initiated
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 1500);
    }

    try {
      // 1. Fetch user's circles
      final circles = await ApiService.getCircles();
      if (circles.isEmpty) {
        debugPrint(
          "BackgroundTriggerService: User is not part of any circle. Cannot trigger SOS.",
        );
        _isTriggering = false;
        return;
      }

      // We will trigger SOS for the first circle in the user's list
      final defaultCircle = circles.first;
      final String circleId = defaultCircle['id'] ?? defaultCircle['circle_id'];

      // 2. Fetch current location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      double? latitude;
      double? longitude;
      String? address;
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
        address = await _resolveAddress(latitude, longitude);
      }

      // 3. Invoke SOS API
      final result = await ApiService.triggerSos(
        circleId: circleId,
        latitude: latitude,
        longitude: longitude,
        address: address ?? "Background Gesture SOS Trigger",
      );

      debugPrint(
        "BackgroundTriggerService: SOS triggered successfully: $result",
      );

      // Notify the user locally that the SOS was dispatched successfully
      await NotificationService.showLocalNotification(
        title: "SOS Broadcast Dispatched",
        body: "Your circle has been notified of your emergency.", payload: jsonEncode({}),
      );
    } catch (e) {
      debugPrint(
        "BackgroundTriggerService: Error triggering background SOS: $e",
      );

      // Vibrate in an error pattern if we fail to send
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
      }
    } finally {
      _isTriggering = false;
    }
  }

  Future<String?> _resolveAddress(double latitude, double longitude) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      final parts = [
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea,
      ];
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
