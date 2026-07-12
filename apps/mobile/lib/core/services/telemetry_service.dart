import 'dart:async';
import 'dart:developer';

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  const TelemetryService._();

  static bool _aptabaseEnabled = false;

  static Future<void> initialize({required String aptabaseAppKey}) async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        unawaited(
          trackEvent('flutter_error', {
            'exception': details.exceptionAsString(),
            'library': details.library,
            'context': details.context?.toDescription(),
          }),
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(recordError(error, stack, fatal: true));
        return true;
      };
    }

    final trimmedKey = aptabaseAppKey.trim();
    if (trimmedKey.isEmpty) {
      log('Aptabase disabled: missing APTABASE_APP_KEY.', name: 'Telemetry');
      return;
    }

    try {
      await Aptabase.init(
        trimmedKey,
        InitOptions(printDebugMessages: kDebugMode),
      );
      _aptabaseEnabled = true;
      await trackEvent('app_telemetry_ready');
    } catch (error, stackTrace) {
      _aptabaseEnabled = false;
      log(
        'Aptabase initialization failed.',
        name: 'Telemetry',
        error: error,
        stackTrace: stackTrace,
      );
      await recordError(
        error,
        stackTrace,
        reason: 'Aptabase initialization failed',
      );
    }
  }

  static Future<void> trackEvent(
    String name, [
    Map<String, dynamic>? properties,
  ]) async {
    if (!_aptabaseEnabled) return;
    try {
      await Aptabase.instance.trackEvent(name, properties);
    } catch (error, stackTrace) {
      log(
        'Aptabase trackEvent failed: $name',
        name: 'Telemetry',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    log(
      reason ?? 'Unhandled error',
      name: 'Telemetry',
      error: error,
      stackTrace: stackTrace,
    );

    if (Firebase.apps.isNotEmpty) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    }

    await trackEvent(fatal ? 'fatal_error' : 'nonfatal_error', {
      'reason': ?reason,
      'error': error.toString(),
    });
  }
}
