import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final completer = Completer<String>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (Android) — handled by user input flow
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );

    final verificationId = await completer.future;

    emit(
      state.copyWith(
        status: AuthStatus.codeSent,
        step: AuthStep.otp,
        verificationId: verificationId,
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
  if (state.verificationId == null) {
    emit(
      state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Session expired. Please try again.',
      ),
    );
    return;
  }

  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final fullPhone = '${state.dialCode}${state.phoneNumber}';

    final credential = PhoneAuthProvider.credential(
      verificationId: state.verificationId!,
      smsCode: event.code,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final idToken = await userCredential.user?.getIdToken();

    if (idToken == null) throw Exception('Failed to retrieve Firebase ID token.');

    final responseData = await ApiService.firebaseExchange(fullPhone, idToken);
    final isProfileComplete = responseData['is_profile_complete'] as bool? ?? false;

    if (state.isJoiningCircle && state.inviteCode != null) {
      try {
        await ApiService.joinCircle(state.inviteCode!);
      } catch (e) {
        log('Failed to join circle after OTP: $e');
      }
    }

    if (isProfileComplete) {
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
