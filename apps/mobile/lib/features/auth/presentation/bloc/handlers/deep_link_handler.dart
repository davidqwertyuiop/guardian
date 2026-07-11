import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:guardian/core/services/api_service.dart';
import '../auth_event.dart';
import '../auth_state.dart';

Future<void> onHandleDeepLinkInvite(
  HandleDeepLinkInvite event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  log('Handling deep link invite with code: ${event.code}');
  
  // If the user is already fully authenticated
  if (state.step == AuthStep.completed || state.status == AuthStatus.success && state.step == AuthStep.completed) {
    try {
      log('User is already authenticated. Joining circle immediately.');
      await ApiService.joinCircle(event.code);
      // It's up to the HomeBloc/HomeScreen to refresh the circles list.
      // We emit a successful state to trigger a potential refresh or toast if needed.
    } catch (e) {
      log('Failed to join circle from deep link: $e');
    }
  } else {
    // If the user is not authenticated yet, we save the invite code and flag.
    log('User is not fully authenticated. Saving invite code for onboarding.');
    emit(
      state.copyWith(
        inviteCode: event.code,
        isJoiningCircle: true,
      ),
    );
  }
}
