import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({AuthStep initialStep = AuthStep.welcome})
    : super(AuthState.initial(step: initialStep)) {
    on<CountryChanged>(_onCountryChanged);
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<SubmitPhoneNumber>(_onSubmitPhoneNumber);
    on<SubmitVerificationCode>(_onSubmitVerificationCode);
    on<ResetAuth>(_onResetAuth);
    on<CompleteProfile>(_onCompleteProfile);
    on<NavigateToLogin>(_onNavigateToLogin);
    on<NavigateToWelcome>(_onNavigateToWelcome);
    on<NavigateBack>(_onNavigateBack);
    on<AppStarted>(_onAppStarted);
    on<EnableLocation>(_onEnableLocation);
    on<SkipLocation>(_onSkipLocation);
    on<EnableNotifications>(_onEnableNotifications);
    on<SkipNotifications>(_onSkipNotifications);

    // New circle events
    on<ClickInviteLink>(_onClickInviteLink);
    on<SelectCreateCircle>(_onSelectCreateCircle);
    on<SelectJoinCircle>(_onSelectJoinCircle);
    on<CreateCircle>(_onCreateCircle);
    on<SubmitInviteCode>(_onSubmitInviteCode);
    on<CompleteCircleOnboarding>(_onCompleteCircleOnboarding);
    on<NavigateToPasteLink>(_onNavigateToPasteLink);
    on<SubmitInviteLink>(_onSubmitInviteLink);
  }

  void _onCountryChanged(CountryChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(countryCode: event.countryCode, dialCode: event.dialCode),
    );
  }

  void _onPhoneNumberChanged(
    PhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final prefs = locator<SharedPreferences>();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    final token = await TokenManager().getAccessToken();
    final hasJwt = token != null && token.isNotEmpty;

    if (onboardingCompleted && hasJwt) {
      emit(state.copyWith(step: AuthStep.completed));
    } else {
      emit(state.copyWith(step: AuthStep.welcome));
    }
  }

  Future<void> _onSubmitPhoneNumber(
    SubmitPhoneNumber event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final fullPhone = '${state.dialCode}${state.phoneNumber}';
      final completer = Completer<String>();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android)
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
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
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSubmitVerificationCode(
    SubmitVerificationCode event,
    Emitter<AuthState> emit,
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

      // Verify with Firebase
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: event.code,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception("Failed to retrieve Firebase ID token.");
      }

      // Exchange for Guardian JWTs
      final responseData = await ApiService.firebaseExchange(
        fullPhone,
        idToken,
      );

      final isProfileComplete =
          responseData['is_profile_complete'] as bool? ?? false;

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
          emit(
            state.copyWith(
              status: AuthStatus.success,
              step: AuthStep.completed,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(status: AuthStatus.success, step: AuthStep.profile),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCompleteProfile(
    CompleteProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      try {
        await ApiService.updateProfile(event.username);
      } catch (e) {
        log('Backend fallback: updateProfile failed ($e). Storing locally.');
        final prefs = locator<SharedPreferences>();
        await prefs.setString('username', event.username);
      }

      emit(
        state.copyWith(
          status: AuthStatus.profileCompleted,
          step: AuthStep.location,
          username: event.username,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onEnableLocation(
    EnableLocation event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentStatus = await Permission.location.status;
      PermissionStatus status;
      if (currentStatus.isPermanentlyDenied) {
        await openAppSettings();
        status = await Permission.location.status;
      } else {
        status = await Permission.location.request();
      }
      final granted = status.isGranted || status.isLimited;
      final prefs = locator<SharedPreferences>();
      await prefs.setBool('location_enabled', granted);
      await _syncPreferencesToBackend();
    } catch (e) {
      log('Permission request failed: $e');
    }
    emit(state.copyWith(step: AuthStep.notifications));
  }

  Future<void> _onSkipLocation(
    SkipLocation event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = locator<SharedPreferences>();
    await prefs.setBool('location_enabled', false);
    await _syncPreferencesToBackend();
    emit(state.copyWith(step: AuthStep.notifications));
  }

  Future<void> _onEnableNotifications(
    EnableNotifications event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final status = await Permission.notification.request();
      final granted = status.isGranted;
      final prefs = locator<SharedPreferences>();
      await prefs.setBool('notifications_enabled', granted);
      await _syncPreferencesToBackend();
    } catch (e) {
      log('Permission request failed: $e');
    }
    if (state.isJoiningCircle) {
      emit(
        state.copyWith(
          step: AuthStep.notifications,
          status: AuthStatus.success,
        ),
      );
    } else {
      emit(state.copyWith(step: AuthStep.almostIn));
    }
  }

  Future<void> _onSkipNotifications(
    SkipNotifications event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = locator<SharedPreferences>();
    await prefs.setBool('notifications_enabled', false);
    await _syncPreferencesToBackend();
    if (state.isJoiningCircle) {
      emit(
        state.copyWith(
          step: AuthStep.notifications,
          status: AuthStatus.success,
        ),
      );
    } else {
      emit(state.copyWith(step: AuthStep.almostIn));
    }
  }

  Future<void> _syncPreferencesToBackend() async {
    try {
      final prefs = locator<SharedPreferences>();
      final location = prefs.getBool('location_enabled') ?? false;
      final notifications = prefs.getBool('notifications_enabled') ?? false;
      await ApiService.updatePreferences(location, notifications);
    } catch (e) {
      log('Failed to sync preferences to backend: $e');
    }
  }

  // New circle event handlers
  void _onClickInviteLink(ClickInviteLink event, Emitter<AuthState> emit) {
    emit(state.copyWith(step: AuthStep.enterInviteCode, isJoiningCircle: true));
  }

  void _onSelectCreateCircle(
    SelectCreateCircle event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(step: AuthStep.nameCircle));
  }

  void _onSelectJoinCircle(SelectJoinCircle event, Emitter<AuthState> emit) {
    emit(state.copyWith(step: AuthStep.enterInviteCode));
  }

  Future<void> _onCreateCircle(
    CreateCircle event,
    Emitter<AuthState> emit,
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

          if (inviteCode != null) {
            await prefs.setString('invite_code', inviteCode);
          }
          if (inviteLink != null) {
            await prefs.setString('invite_link', inviteLink);
          }
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
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSubmitInviteCode(
    SubmitInviteCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final prefs = locator<SharedPreferences>();
      await prefs.setString('invite_code', event.code);

      // Immediately go to login to authenticate first
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          step: AuthStep.login,
          isJoiningCircle: true,
          inviteCode: event.code,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCompleteCircleOnboarding(
    CompleteCircleOnboarding event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = locator<SharedPreferences>();
    await prefs.setBool('onboarding_completed', true);
    emit(state.copyWith(step: AuthStep.completed));
  }

  void _onResetAuth(ResetAuth event, Emitter<AuthState> emit) {
    emit(AuthState.initial());
  }

  void _onNavigateToLogin(NavigateToLogin event, Emitter<AuthState> emit) {
    emit(state.copyWith(step: AuthStep.login, status: AuthStatus.initial));
  }

  void _onNavigateToWelcome(NavigateToWelcome event, Emitter<AuthState> emit) {
    emit(state.copyWith(step: AuthStep.welcome, status: AuthStatus.initial));
  }

  void _onNavigateBack(NavigateBack event, Emitter<AuthState> emit) {
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
        emit(
          state.copyWith(step: AuthStep.profile, status: AuthStatus.success),
        );
        break;
      case AuthStep.notifications:
        emit(
          state.copyWith(step: AuthStep.location, status: AuthStatus.success),
        );
        break;
      case AuthStep.almostIn:
        emit(
          state.copyWith(
            step: AuthStep.notifications,
            status: AuthStatus.success,
          ),
        );
        break;
      case AuthStep.nameCircle:
        emit(
          state.copyWith(step: AuthStep.almostIn, status: AuthStatus.initial),
        );
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
        emit(
          state.copyWith(step: AuthStep.nameCircle, status: AuthStatus.initial),
        );
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
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _onNavigateToPasteLink(
    NavigateToPasteLink event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(step: AuthStep.pasteLink));
  }

  Future<void> _onSubmitInviteLink(
    SubmitInviteLink event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final link = event.link.trim();
      if (link.isEmpty) {
        // Blank field → show circle empty screen immediately without hitting backend
        emit(
          state.copyWith(
            status: AuthStatus.initial,
            step: AuthStep.circleEmpty,
          ),
        );
        return;
      }

      final prefs = locator<SharedPreferences>();
      await prefs.setString('invite_link', link);

      // 1. Ask backend if the circle behind this link has members
      final hasMembers = await ApiService.checkCircleHasMembers(link);

      if (!hasMembers) {
        // Circle is empty → show CircleEmptyScreen
        emit(
          state.copyWith(
            status: AuthStatus.initial,
            step: AuthStep.circleEmpty,
          ),
        );
        return;
      }

      // 2. Circle has members → attempt to join
      try {
        await ApiService.joinCircle(link);
      } catch (e) {
        log('Backend fallback: joinCircle via link failed ($e)');
      }

      // 3. Go to profile setup; isJoiningCircle=true skips almostIn after notifications
      emit(
        state.copyWith(
          status: AuthStatus.success,
          step: AuthStep.profile,
          isJoiningCircle: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
