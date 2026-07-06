# app_handler.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/bloc/handlers/app_handler.dart`
* **Type:** `DART`

---

```dart
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/security/token_manager.dart';
import '../auth_event.dart';
import '../auth_state.dart';

import 'dart:convert';
import 'dart:developer';

bool _isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    
    final payloadPart = parts[1];
    String normalized = base64Url.normalize(payloadPart);
    String payloadStr = utf8.decode(base64Url.decode(normalized));
    final payload = json.decode(payloadStr) as Map<String, dynamic>;
    
    if (payload.containsKey('exp')) {
      final exp = payload['exp'] as int;
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Add a 10 second buffer to prevent race conditions on fast load
      return DateTime.now().add(const Duration(seconds: 10)).isAfter(expiryTime);
    }
  } catch (e) {
    log('Error decoding JWT token: $e');
    return true;
  }
  return false;
}

Future<void> onAppStarted(
  AppStarted event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  final prefs = locator<SharedPreferences>();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final token = await TokenManager().getAccessToken();
  
  bool isExpired = true;
  if (token != null && token.isNotEmpty) {
    isExpired = _isTokenExpired(token);
  }

  if (onboardingCompleted && token != null && token.isNotEmpty && !isExpired) {
    emit(state.copyWith(step: AuthStep.completed));
  } else {
    // Session is invalid/expired. Clean up state and force welcome onboarding.
    await TokenManager().clearTokens();
    await prefs.setBool('onboarding_completed', false);
    await prefs.remove('username');
    await prefs.remove('user_id');
    emit(state.copyWith(step: AuthStep.welcome));
  }
}

void onResetAuth(
  ResetAuth event,
  Emitter<AuthState> emit,
) {
  emit(AuthState.initial());
}

void onCountryChanged(
  CountryChanged event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(
    state.copyWith(
      countryCode: event.countryCode,
      dialCode: event.dialCode,
    ),
  );
}

void onPhoneNumberChanged(
  PhoneNumberChanged event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(state.copyWith(phoneNumber: event.phoneNumber));
}

```
