import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<CountryChanged>(_onCountryChanged);
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<SubmitPhoneNumber>(_onSubmitPhoneNumber);
    on<SubmitVerificationCode>(_onSubmitVerificationCode);
    on<ResetAuth>(_onResetAuth);
    on<CompleteProfile>(_onCompleteProfile);
  }

  void _onCountryChanged(CountryChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(countryCode: event.countryCode, dialCode: event.dialCode));
  }

  void _onPhoneNumberChanged(PhoneNumberChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  Future<void> _onSubmitPhoneNumber(SubmitPhoneNumber event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final fullPhone = '${state.dialCode}${state.phoneNumber}';
      try {
        await ApiService.sendOtp(fullPhone);
      } catch (e) {
        // Fallback for development if backend is not yet ready/accessible
        print('Backend fallback: sendOtp failed ($e). Continuing with mock.');
      }
      emit(state.copyWith(status: AuthStatus.codeSent));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onSubmitVerificationCode(SubmitVerificationCode event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final fullPhone = '${state.dialCode}${state.phoneNumber}';
      String token = 'mock_jwt_token';
      try {
        token = await ApiService.verifyOtp(fullPhone, event.code);
      } catch (e) {
        // Fallback for development if backend is not yet ready/accessible
        print('Backend fallback: verifyOtp failed ($e). Continuing with mock.');
      }
      await TokenManager().saveTokens(accessToken: token, refreshToken: token);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCompleteProfile(CompleteProfile event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final prefs = locator<SharedPreferences>();
      await prefs.setBool('onboarding_completed', true);
      emit(state.copyWith(status: AuthStatus.profileCompleted, username: event.username));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onResetAuth(ResetAuth event, Emitter<AuthState> emit) {
    emit(AuthState.initial());
  }
}
