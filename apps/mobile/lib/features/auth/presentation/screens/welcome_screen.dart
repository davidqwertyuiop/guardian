import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/core/theme/smooth_page_route.dart';
import 'package:guardian/features/auth/presentation/widgets/welcome_card.dart';
import 'package:guardian/features/location/presentation/screens/live_map_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';
import 'location_permission_screen.dart';
import 'notifications_permission_screen.dart';
import 'almost_in_screen.dart';
import 'name_circle_screen.dart';
import 'enter_invite_code_screen.dart';
import 'circle_empty_screen.dart';
import 'paste_link_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  AuthStep _currentStep = AuthStep.splash;

  @override
  void initState() {
    super.initState();
    _currentStep = locator<AuthBloc>().state.step;
  }

  void _handleStepTransition(AuthStep newStep) {
    if (newStep == _currentStep) return;

    final oldStep = _currentStep;
    setState(() {
      _currentStep = newStep;
    });

    if (newStep == AuthStep.completed) {
      Navigator.of(context).pushAndRemoveUntil(
        SmoothPageRoute(child: const LiveMapScreen()),
        (route) => false,
      );
      return;
    }

    Widget getScreen(AuthStep step) {
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
        default:
          return const WelcomeStepView();
      }
    }

    bool isBackTransition(AuthStep oldS, AuthStep newS) {
      if (oldS == AuthStep.login && newS == AuthStep.welcome) return true;
      if (oldS == AuthStep.otp && newS == AuthStep.login) return true;
      if (oldS == AuthStep.profile && newS == AuthStep.otp) return true;
      if (oldS == AuthStep.profile && newS == AuthStep.enterInviteCode) {
        return true;
      }
      if (oldS == AuthStep.location && newS == AuthStep.profile) return true;
      if (oldS == AuthStep.notifications && newS == AuthStep.location) {
        return true;
      }
      if (oldS == AuthStep.almostIn && newS == AuthStep.notifications) {
        return true;
      }
      if (oldS == AuthStep.nameCircle && newS == AuthStep.almostIn) return true;
      if (oldS == AuthStep.enterInviteCode && newS == AuthStep.almostIn) {
        return true;
      }
      if (oldS == AuthStep.enterInviteCode && newS == AuthStep.welcome) {
        return true;
      }
      if (oldS == AuthStep.circleEmpty && newS == AuthStep.nameCircle) {
        return true;
      }
      if (oldS == AuthStep.pasteLink && newS == AuthStep.enterInviteCode) {
        return true;
      }
      return false;
    }

    if (isBackTransition(oldStep, newStep)) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).push(SmoothPageRoute(child: getScreen(newStep)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: locator<AuthBloc>(),
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) => _handleStepTransition(state.step),
      child: const WelcomeStepView(),
    );
  }
}

class SplashStepView extends StatelessWidget {
  const SplashStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.logo,
              width: AdaptiveLayout.w(context, 100),
              height: AdaptiveLayout.h(context, 100),
              fit: BoxFit.contain,
            ),
            SizedBox(height: AdaptiveLayout.h(context, 16)),
            Text(
              'guardian',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AdaptiveLayout.sp(context, 32),
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeStepView extends StatelessWidget {
  const WelcomeStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = AdaptiveLayout.isLandscape(context);
    final isShort = MediaQuery.sizeOf(context).height < 720;

    final content = Column(
      children: [
        const WelcomeCard(),
        if (isLandscape || isShort)
          SizedBox(height: AdaptiveLayout.h(context, 24))
        else
          const Spacer(),
        _buildButtons(context, isDark),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Welcome screen is root of onboarding, back does nothing
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: AdaptiveLayout.padding(context, 16),
              right: AdaptiveLayout.padding(context, 16),
              bottom: AdaptiveLayout.padding(context, 16),
              top: AdaptiveLayout.padding(context, 50),
            ),
            child: (isLandscape || isShort)
                ? SingleChildScrollView(
                    child: SizedBox(height: 440, child: content),
                  )
                : content,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: AdaptiveLayout.h(context, 54),
          child: ElevatedButton(
            onPressed: () => locator<AuthBloc>().add(const NavigateToLogin()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Create an account',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: AdaptiveLayout.sp(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: AdaptiveLayout.h(context, 12)),
        SizedBox(
          width: double.infinity,
          height: AdaptiveLayout.h(context, 54),
          child: TextButton(
            onPressed: () => locator<AuthBloc>().add(const ClickInviteLink()),
            style: TextButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF1E1E22)
                  : const Color(0xFFF3F3F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'I have an invite link',
              style: TextStyle(
                fontFamily: 'Inter',
                color: isDark ? Colors.white : Colors.black,
                fontSize: AdaptiveLayout.sp(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
