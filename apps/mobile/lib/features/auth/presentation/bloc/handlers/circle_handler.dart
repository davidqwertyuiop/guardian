import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/services/api_service.dart';
import '../auth_event.dart';
import '../auth_state.dart';

void onClickInviteLink(
  ClickInviteLink event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(state.copyWith(step: AuthStep.enterInviteCode, isJoiningCircle: true));
}

void onSelectCreateCircle(
  SelectCreateCircle event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(state.copyWith(step: AuthStep.nameCircle));
}

void onSelectJoinCircle(
  SelectJoinCircle event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(state.copyWith(step: AuthStep.enterInviteCode));
}

Future<void> onCreateCircle(
  CreateCircle event,
  Emitter<AuthState> emit,
  AuthState state,
  String Function(dynamic) parseError,
) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final prefs = locator<SharedPreferences>();
    await prefs.setString('circle_name', event.circleName);

    String? inviteCode;
    String? inviteLink;

    try {
      final res = await ApiService.createCircle(event.circleName);
      final invite = res['invite'] as Map<String, dynamic>?;
      if (invite != null) {
        inviteCode = invite['code'] as String?;
        inviteLink = invite['invite_link'] as String?;
        if (inviteCode != null) await prefs.setString('invite_code', inviteCode);
        if (inviteLink != null) await prefs.setString('invite_link', inviteLink);
      }
    } catch (e) {
      log('Backend fallback: createCircle failed ($e)');
    }

    emit(
      state.copyWith(
        status: AuthStatus.success,
        inviteCode: inviteCode,
        inviteLink: inviteLink,
      ),
    );
  } catch (e) {
    emit(state.copyWith(status: AuthStatus.failure, errorMessage: parseError(e)));
  }
}

Future<void> onSubmitInviteCode(
  SubmitInviteCode event,
  Emitter<AuthState> emit,
  AuthState state,
  String Function(dynamic) parseError,
) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final prefs = locator<SharedPreferences>();
    await prefs.setString('invite_code', event.code);

    emit(
      state.copyWith(
        status: AuthStatus.initial,
        step: AuthStep.login,
        isJoiningCircle: true,
        inviteCode: event.code,
      ),
    );
  } catch (e) {
    emit(state.copyWith(status: AuthStatus.failure, errorMessage: parseError(e)));
  }
}

Future<void> onCompleteCircleOnboarding(
  CompleteCircleOnboarding event,
  Emitter<AuthState> emit,
  AuthState state,
) async {
  final prefs = locator<SharedPreferences>();
  await prefs.setBool('onboarding_completed', true);
  emit(state.copyWith(step: AuthStep.completed));
}

void onNavigateToPasteLink(
  NavigateToPasteLink event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(state.copyWith(step: AuthStep.pasteLink));
}

Future<void> onSubmitInviteLink(
  SubmitInviteLink event,
  Emitter<AuthState> emit,
  AuthState state,
  String Function(dynamic) parseError,
) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final link = event.link.trim();
    if (link.isEmpty) {
      emit(state.copyWith(status: AuthStatus.initial, step: AuthStep.circleEmpty));
      return;
    }

    final prefs = locator<SharedPreferences>();
    await prefs.setString('invite_link', link);

    final hasMembers = await ApiService.checkCircleHasMembers(link);

    if (!hasMembers) {
      emit(state.copyWith(status: AuthStatus.initial, step: AuthStep.circleEmpty));
      return;
    }

    try {
      await ApiService.joinCircle(link);
    } catch (e) {
      log('Backend fallback: joinCircle via link failed ($e)');
    }

    emit(
      state.copyWith(
        status: AuthStatus.success,
        step: AuthStep.profile,
        isJoiningCircle: true,
      ),
    );
  } catch (e) {
    emit(state.copyWith(status: AuthStatus.failure, errorMessage: parseError(e)));
  }
}
