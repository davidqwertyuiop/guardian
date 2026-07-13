import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_onboarding_router.dart';
import 'welcome_step_view.dart';
import 'package:guardian/export.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  AuthStep _currentStep = AuthStep.splash;
  AuthStep? _pushedStep;

  @override
  void initState() {
    super.initState();
    _currentStep = context.read<AuthBloc>().state.step;
  }

  Future<void> _handleStepTransition(AuthState state) async {
    final newStep = state.step;
    final oldStep = _currentStep;
    if (newStep == _currentStep) return;

    if (mounted) {
      setState(() {
        _currentStep = newStep;
      });
    }

    if (newStep == AuthStep.completed) {
      return;
    }

    if (!state.triggerNavigation) return;

    if (AuthOnboardingRouter.isBackTransition(oldStep, newStep)) {
      _pushedStep = null;
      final navigator = Navigator.of(context);
      if (!(ModalRoute.of(context)?.isCurrent ?? false) &&
          navigator.canPop()) {
        navigator.pop();
      }
    } else {
      if (_pushedStep == newStep) return;
      _pushedStep = newStep;
      await Navigator.of(context).push(AuthOnboardingRouter.routeFor(newStep));
      if (!mounted) return;
      if (context.read<AuthBloc>().state.step == newStep) {
        _pushedStep = null;
        context.read<AuthBloc>().add(const NavigateBack(isNativePop: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: context.read<AuthBloc>(),
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        unawaited(_handleStepTransition(state));
      },
      child: _currentStep == AuthStep.splash
          ? const SplashStepView()
          : const WelcomeStepView(),
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
