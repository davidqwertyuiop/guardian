import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/core/services/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<CountryChanged>(_onCountryChanged);
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<SubmitPhoneNumber>(_onSubmitPhoneNumber);
    on<SubmitVerificationCode>(_onSubmitVerificationCode);
    on<ResetAuth>(_onResetAuth);
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
      await ApiService.sendOtp(fullPhone);
      emit(state.copyWith(status: AuthStatus.codeSent));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSubmitVerificationCode(SubmitVerificationCode event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final fullPhone = '${state.dialCode}${state.phoneNumber}';
      final token = await ApiService.verifyOtp(fullPhone, event.code);
      
      // Save token securely in TokenManager
      await TokenManager().saveTokens(accessToken: token, refreshToken: token);

      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onResetAuth(ResetAuth event, Emitter<AuthState> emit) {
    emit(AuthState.initial());
  }
}
