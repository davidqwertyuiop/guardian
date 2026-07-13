import 'package:bloc/bloc.dart';
import '../auth_event.dart';
import '../auth_state.dart';

void onNavigateBack(
  NavigateBack event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  switch (state.step) {
    case AuthStep.splash:
    case AuthStep.welcome:
      break;
    case AuthStep.login:
      if (state.isJoiningCircle) {
        emit(
          state.copyWith(
            step: AuthStep.enterInviteCode,
            status: AuthStatus.initial,
          ),
        );
      } else {
        emit(
          state.copyWith(
            step: AuthStep.welcome,
            status: AuthStatus.initial,
            isJoiningCircle: false,
          ),
        );
      }
      break;
    case AuthStep.otp:
      emit(state.copyWith(step: AuthStep.login, status: AuthStatus.initial));
      break;
    case AuthStep.profile:
      if (state.isJoiningCircle) {
        emit(
          state.copyWith(
            step: AuthStep.enterInviteCode,
            status: AuthStatus.initial,
          ),
        );
      } else {
        emit(state.copyWith(step: AuthStep.otp, status: AuthStatus.codeSent));
      }
      break;
    case AuthStep.location:
      emit(state.copyWith(step: AuthStep.profile, status: AuthStatus.success));
      break;
    case AuthStep.notifications:
      emit(state.copyWith(step: AuthStep.location, status: AuthStatus.success));
      break;
    case AuthStep.almostIn:
      emit(
        state.copyWith(step: AuthStep.notifications, status: AuthStatus.success),
      );
      break;
    case AuthStep.nameCircle:
      emit(state.copyWith(step: AuthStep.almostIn, status: AuthStatus.initial));
      break;
    case AuthStep.enterInviteCode:
      if (state.isJoiningCircle) {
        // Reached from welcome screen's "I have an invite link" button.
        emit(
          state.copyWith(
            step: AuthStep.welcome,
            status: AuthStatus.initial,
            isJoiningCircle: false,
            triggerNavigation: !event.isNativePop,
          ),
        );
      } else {
        // Reached from almostIn via "Join circle" button.
        emit(
          state.copyWith(step: AuthStep.almostIn, status: AuthStatus.initial),
        );
      }
      break;
    case AuthStep.circleEmpty:
      emit(state.copyWith(step: AuthStep.nameCircle, status: AuthStatus.initial));
      break;
    case AuthStep.pasteLink:
      emit(
        state.copyWith(
          step: AuthStep.enterInviteCode,
          status: AuthStatus.initial,
          triggerNavigation: !event.isNativePop,
        ),
      );
      break;
    case AuthStep.completed:
      break;
    case AuthStep.youAreIn:
      break;
  }
}

void onNavigateToLogin(
  NavigateToLogin event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(
    state.copyWith(
      step: AuthStep.login,
      status: AuthStatus.initial,
      triggerNavigation: true,
    ),
  );
}

void onNavigateToWelcome(
  NavigateToWelcome event,
  Emitter<AuthState> emit,
  AuthState state,
) {
  emit(
    state.copyWith(
      step: AuthStep.welcome,
      status: AuthStatus.initial,
      triggerNavigation: true,
    ),
  );
}
