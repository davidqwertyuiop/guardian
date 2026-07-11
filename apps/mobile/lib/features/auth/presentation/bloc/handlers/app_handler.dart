import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/security/token_manager.dart';
import '../auth_token_inspector.dart';
import '../auth_event.dart';
import '../auth_state.dart';

Future<void> onAppStarted(
  AppStarted event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  final prefs = locator<SharedPreferences>();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final refreshToken = await TokenManager().getRefreshToken();

  bool isRefreshExpired = true;
  if (refreshToken != null && refreshToken.isNotEmpty) {
    isRefreshExpired = AuthTokenInspector.isExpired(refreshToken);
  }

  if (onboardingCompleted && refreshToken != null && refreshToken.isNotEmpty && !isRefreshExpired) {
    // Attempt to pre-emptively load or refresh access token
    final token = await TokenManager().getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(step: AuthStep.completed));
      return;
    }
  }

  // Session is invalid/expired (older than 1 month) or onboarding is incomplete.
  // Clean up state and force welcome onboarding.
  await TokenManager().clearTokens();
  await prefs.setBool('onboarding_completed', false);
  await prefs.remove('username');
  await prefs.remove('user_id');
  emit(state.copyWith(step: AuthStep.welcome));
}

void onResetAuth(ResetAuth event, Emitter<AuthState> emit) {
  emit(AuthState.initial());
}

void onCountryChanged(
  CountryChanged event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(
    state.copyWith(countryCode: event.countryCode, dialCode: event.dialCode),
  );
}

void onPhoneNumberChanged(
  PhoneNumberChanged event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(state.copyWith(phoneNumber: event.phoneNumber));
}
