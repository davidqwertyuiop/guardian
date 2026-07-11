import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/core/services/api_service.dart';
import '../auth_event.dart';
import '../auth_state.dart';

Future<void> onSubmitPhoneNumber(
  SubmitPhoneNumber event,
  Emitter<AuthState> emit,
  AuthState state,
  String Function(dynamic) parseError,
) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final fullPhone = '${state.dialCode}${state.phoneNumber}';

    await ApiService.sendOtp(fullPhone);

    emit(
      state.copyWith(
        status: AuthStatus.codeSent,
        step: AuthStep.otp,
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

Future<void> onSubmitVerificationCode(
  SubmitVerificationCode event,
  Emitter<AuthState> emit,
  AuthState state,
  String Function(dynamic) parseError,
) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final fullPhone = '${state.dialCode}${state.phoneNumber}';

    final responseData = await ApiService.verifyOtp(fullPhone, event.code);
    final isProfileComplete = responseData['is_profile_complete'] as bool? ?? false;

    if (state.isJoiningCircle && state.inviteCode != null) {
      try {
        await ApiService.joinCircle(state.inviteCode!);
      } catch (e) {
        log('Failed to join circle after OTP: $e');
      }
    }

    if (isProfileComplete) {
      try {
        final profile = await ApiService.getMe();
        final name = profile['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', name);
        }
      } catch (e) {
        log('Failed to pre-fetch profile username on login: $e');
      }

      if (state.isJoiningCircle) {
        emit(state.copyWith(status: AuthStatus.success, step: AuthStep.otp));
      } else {
        emit(state.copyWith(status: AuthStatus.success, step: AuthStep.completed));
      }
    } else {
      emit(state.copyWith(status: AuthStatus.success, step: AuthStep.profile));
    }
  } catch (e) {
    emit(
      state.copyWith(
        status: AuthStatus.failure,
        errorMessage: parseError(e),
      ),
    );
  }
}
