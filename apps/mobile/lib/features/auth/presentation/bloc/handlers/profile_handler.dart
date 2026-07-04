import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/services/api_service.dart';
import '../auth_event.dart';
import '../auth_state.dart';

Future<void> onCompleteProfile(
  CompleteProfile event,
  Emitter<AuthState> emit,
  AuthState state,
  String Function(dynamic) parseError,
) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final prefs = locator<SharedPreferences>();
    await prefs.setString('username', event.username);
    await prefs.setString('country_code', state.countryCode);
    
    try {
      await ApiService.updateProfile(event.username);
    } catch (e) {
      log('Backend fallback: updateProfile failed ($e).');
    }

    emit(
      state.copyWith(
        status: AuthStatus.profileCompleted,
        step: AuthStep.location,
        username: event.username,
      ),
    );
  } catch (e) {
    emit(
      state.copyWith(
        status: AuthStatus.failure,
        errorMessage: parseError(e),
      ),
    );
  }
}

Future<void> onEnableLocation(
  EnableLocation event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  try {
    final currentStatus = await Permission.location.status;
    PermissionStatus status;
    if (currentStatus.isPermanentlyDenied) {
      await openAppSettings();
      status = await Permission.location.status;
    } else {
      status = await Permission.location.request();
    }
    final granted = status.isGranted || status.isLimited;

    // Prompt to turn on GPS settings if location service is disabled
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      log('Geolocator service check failed: $e');
    }

    final prefs = locator<SharedPreferences>();
    await prefs.setBool('location_enabled', granted);
    await _syncPreferencesToBackend();
  } catch (e) {
    log('Permission request failed: $e');
  }
  emit(state.copyWith(step: AuthStep.notifications));
}

Future<void> onSkipLocation(
  SkipLocation event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  final prefs = locator<SharedPreferences>();
  await prefs.setBool('location_enabled', false);
  await _syncPreferencesToBackend();
  emit(state.copyWith(step: AuthStep.notifications));
}

Future<void> onEnableNotifications(
  EnableNotifications event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  try {
    final status = await Permission.notification.request();
    final granted = status.isGranted;

    // Prompt to turn on GPS settings if location service is disabled (safety fallback)
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      log('Geolocator service check failed: $e');
    }

    final prefs = locator<SharedPreferences>();
    await prefs.setBool('notifications_enabled', granted);
    await _syncPreferencesToBackend();
  } catch (e) {
    log('Permission request failed: $e');
  }
  if (state.isJoiningCircle) {
    emit(state.copyWith(step: AuthStep.notifications, status: AuthStatus.success));
  } else {
    emit(state.copyWith(step: AuthStep.almostIn));
  }
}

Future<void> onSkipNotifications(
  SkipNotifications event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  final prefs = locator<SharedPreferences>();
  await prefs.setBool('notifications_enabled', false);
  await _syncPreferencesToBackend();
  if (state.isJoiningCircle) {
    emit(state.copyWith(step: AuthStep.notifications, status: AuthStatus.success));
  } else {
    emit(state.copyWith(step: AuthStep.almostIn));
  }
}

Future<void> _syncPreferencesToBackend() async {
  try {
    final prefs = locator<SharedPreferences>();
    final location = prefs.getBool('location_enabled') ?? false;
    final notifications = prefs.getBool('notifications_enabled') ?? false;
    await ApiService.updatePreferences(location, notifications);
  } catch (e) {
    log('Failed to sync preferences to backend: $e');
  }
}
