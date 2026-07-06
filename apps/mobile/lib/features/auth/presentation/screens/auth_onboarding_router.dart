import 'package:flutter/cupertino.dart';

import 'package:guardian/core/theme/smooth_page_route.dart';
import 'package:guardian/features/circles/presentation/screens/circle_empty_screen.dart';
import 'package:guardian/features/circles/presentation/screens/enter_invite_code_screen.dart';
import 'package:guardian/features/circles/presentation/screens/name_circle_screen.dart';
import 'package:guardian/features/circles/presentation/screens/paste_link_screen.dart';
import 'package:guardian/features/location/presentation/screens/location_permission_screen.dart';
import 'package:guardian/features/notifications/presentation/screens/notifications_permission_screen.dart';

import '../bloc/auth_state.dart';
import 'almost_in_screen.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';
import 'welcome_step_view.dart';

class AuthOnboardingRouter {
  const AuthOnboardingRouter._();

  static Widget screenFor(AuthStep step) {
    switch (step) {
      case AuthStep.welcome:
        return const WelcomeStepView();
      case AuthStep.login:
        return const LoginScreen();
      case AuthStep.otp:
        return const OtpScreen();
      case AuthStep.profile:
        return const RegisterScreen();
      case AuthStep.location:
        return const LocationPermissionScreen();
      case AuthStep.notifications:
        return const NotificationsPermissionScreen();
      case AuthStep.almostIn:
        return const AlmostInScreen();
      case AuthStep.nameCircle:
        return const NameCircleScreen();
      case AuthStep.enterInviteCode:
        return const EnterInviteCodeScreen();
      case AuthStep.pasteLink:
        return const PasteLinkScreen();
      case AuthStep.circleEmpty:
        return const CircleEmptyScreen();
      case AuthStep.splash:
      case AuthStep.completed:
      case AuthStep.youAreIn:
        return const WelcomeStepView();
    }
  }

  static Route<void> routeFor(AuthStep step) {
    final screen = screenFor(step);
    if (step == AuthStep.enterInviteCode || step == AuthStep.pasteLink) {
      return CupertinoPageRoute(builder: (_) => screen);
    }
    return SmoothPageRoute(child: screen);
  }

  static bool isBackTransition(AuthStep oldStep, AuthStep newStep) {
    return _backTransitions.contains((oldStep, newStep));
  }

  static const Set<(AuthStep, AuthStep)> _backTransitions = {
    (AuthStep.login, AuthStep.welcome),
    (AuthStep.login, AuthStep.enterInviteCode),
    (AuthStep.otp, AuthStep.login),
    (AuthStep.profile, AuthStep.otp),
    (AuthStep.profile, AuthStep.enterInviteCode),
    (AuthStep.location, AuthStep.profile),
    (AuthStep.notifications, AuthStep.location),
    (AuthStep.almostIn, AuthStep.notifications),
    (AuthStep.nameCircle, AuthStep.almostIn),
    (AuthStep.enterInviteCode, AuthStep.almostIn),
    (AuthStep.enterInviteCode, AuthStep.welcome),
    (AuthStep.circleEmpty, AuthStep.nameCircle),
    (AuthStep.pasteLink, AuthStep.enterInviteCode),
  };
}
