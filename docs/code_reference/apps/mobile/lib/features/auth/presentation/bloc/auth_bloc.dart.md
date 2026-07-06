# auth_bloc.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/bloc/auth_bloc.dart`
* **Type:** `DART`

---

```dart
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'handlers/app_handler.dart' as app;
import 'handlers/phone_auth_handler.dart' as phone;
import 'handlers/profile_handler.dart' as profile;
import 'handlers/circle_handler.dart' as circle;
import 'handlers/navigation_handler.dart' as nav;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthStep initialStep = AuthStep.welcome})
    : super(AuthState.initial(step: initialStep)) {
    on<AppStarted>((e, emit) => app.onAppStarted(e, emit, state));
    on<ResetAuth>((e, emit) => app.onResetAuth(e, emit));
    on<CountryChanged>((e, emit) => app.onCountryChanged(e, emit, state));
    on<PhoneNumberChanged>((e, emit) => app.onPhoneNumberChanged(e, emit, state));

    on<SubmitPhoneNumber>(
      (e, emit) => phone.onSubmitPhoneNumber(e, emit, state, _parseError),
    );
    on<SubmitVerificationCode>(
      (e, emit) => phone.onSubmitVerificationCode(e, emit, state, _parseError),
    );

    on<CompleteProfile>(
      (e, emit) => profile.onCompleteProfile(e, emit, state, _parseError),
    );
    on<EnableLocation>((e, emit) => profile.onEnableLocation(e, emit, state));
    on<SkipLocation>((e, emit) => profile.onSkipLocation(e, emit, state));
    on<EnableNotifications>(
      (e, emit) => profile.onEnableNotifications(e, emit, state),
    );
    on<SkipNotifications>(
      (e, emit) => profile.onSkipNotifications(e, emit, state),
    );

    on<ClickInviteLink>(
      (e, emit) => circle.onClickInviteLink(e, emit, state),
    );
    on<SelectCreateCircle>(
      (e, emit) => circle.onSelectCreateCircle(e, emit, state),
    );
    on<SelectJoinCircle>(
      (e, emit) => circle.onSelectJoinCircle(e, emit, state),
    );
    on<CreateCircle>(
      (e, emit) => circle.onCreateCircle(e, emit, state, _parseError),
    );
    on<SubmitInviteCode>(
      (e, emit) => circle.onSubmitInviteCode(e, emit, state, _parseError),
    );
    on<CompleteCircleOnboarding>(
      (e, emit) => circle.onCompleteCircleOnboarding(e, emit, state),
    );
    on<NavigateToPasteLink>(
      (e, emit) => circle.onNavigateToPasteLink(e, emit, state),
    );
    on<SubmitInviteLink>(
      (e, emit) => circle.onSubmitInviteLink(e, emit, state, _parseError),
    );

    on<NavigateBack>((e, emit) => nav.onNavigateBack(e, emit, state));
    on<NavigateToLogin>((e, emit) => nav.onNavigateToLogin(e, emit, state));
    on<NavigateToWelcome>((e, emit) => nav.onNavigateToWelcome(e, emit, state));
  }

  String _parseError(dynamic error) {
    final s = error.toString();
    if (s.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (s.contains('invalid-verification-code')) {
      return 'Invalid code. Please check and try again.';
    }
    if (s.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (s.contains('user-disabled')) return 'This account has been disabled.';
    if (s.contains('session-expired')) {
      return 'Session expired. Please request a new code.';
    }
    if (error is FirebaseAuthException) {
      return error.message ?? 'An authentication error occurred.';
    }
    if (s.startsWith('Exception: ')) return s.substring(11);
    return s;
  }
}

```
