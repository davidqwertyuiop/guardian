import 'package:flutter/material.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardian/features/auth/presentation/widgets/onboarding_step_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScreen(
      title: 'Guardian needs your location',
      subtitle:
          'So your circle knows you\'re safe — even when the app is closed.',
      bulletPoints: const [
        'Your circle sees where you are',
        'You always control who sees it',
        'You can pause or stop anytime',
      ],
      primaryButtonText: 'Turn on location',
      secondaryButtonText: 'Not now — I\'ll do this later',
      onPrimaryPressed: () {
        locator<AuthBloc>().add(const EnableLocation());
      },
      onSecondaryPressed: () {
        locator<AuthBloc>().add(const SkipLocation());
      },
    );
  }
}
