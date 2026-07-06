# location_permission_screen.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/screens/location_permission_screen.dart`
* **Type:** `DART`

---

```dart

import 'package:flutter/material.dart';

import 'package:guardian/export.dart';
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
        context.read<AuthBloc>().add(const EnableLocation());
      },
      onSecondaryPressed: () {
        context.read<AuthBloc>().add(const SkipLocation());
      },
    );
  }
}

```
