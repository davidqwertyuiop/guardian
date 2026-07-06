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
  final token = await TokenManager().getAccessToken();

  bool isExpired = true;
  if (token != null && token.isNotEmpty) {
    isExpired = AuthTokenInspector.isExpired(token);
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
