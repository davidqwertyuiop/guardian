import 'package:bloc/bloc.dart';
import 'auth_error_parser.dart';
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
    on<PhoneNumberChanged>(
      (e, emit) => app.onPhoneNumberChanged(e, emit, state),
    );

    on<SubmitPhoneNumber>(
      (e, emit) =>
          phone.onSubmitPhoneNumber(e, emit, state, AuthErrorParser.parse),
    );
    on<SubmitVerificationCode>(
      (e, emit) =>
          phone.onSubmitVerificationCode(e, emit, state, AuthErrorParser.parse),
    );

    on<CompleteProfile>(
      (e, emit) =>
          profile.onCompleteProfile(e, emit, state, AuthErrorParser.parse),
    );
    on<EnableLocation>((e, emit) => profile.onEnableLocation(e, emit, state));
    on<SkipLocation>((e, emit) => profile.onSkipLocation(e, emit, state));
    on<EnableNotifications>(
      (e, emit) => profile.onEnableNotifications(e, emit, state),
    );
    on<SkipNotifications>(
      (e, emit) => profile.onSkipNotifications(e, emit, state),
    );

    on<ClickInviteLink>((e, emit) => circle.onClickInviteLink(e, emit, state));
    on<SelectCreateCircle>(
      (e, emit) => circle.onSelectCreateCircle(e, emit, state),
    );
    on<SelectJoinCircle>(
      (e, emit) => circle.onSelectJoinCircle(e, emit, state),
    );
    on<CreateCircle>(
      (e, emit) => circle.onCreateCircle(e, emit, state, AuthErrorParser.parse),
    );
    on<SubmitInviteCode>(
      (e, emit) =>
          circle.onSubmitInviteCode(e, emit, state, AuthErrorParser.parse),
    );
    on<CompleteCircleOnboarding>(
      (e, emit) => circle.onCompleteCircleOnboarding(e, emit, state),
    );
    on<NavigateToPasteLink>(
      (e, emit) => circle.onNavigateToPasteLink(e, emit, state),
    );
    on<SubmitInviteLink>(
      (e, emit) =>
          circle.onSubmitInviteLink(e, emit, state, AuthErrorParser.parse),
    );

    on<NavigateBack>((e, emit) => nav.onNavigateBack(e, emit, state));
    on<NavigateToLogin>((e, emit) => nav.onNavigateToLogin(e, emit, state));
    on<NavigateToWelcome>((e, emit) => nav.onNavigateToWelcome(e, emit, state));
  }
}
