# onboarding_top_icon.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/widgets/onboarding_top_icon.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';

class OnboardingTopIcon extends StatelessWidget {
  final bool isDark;

  const OnboardingTopIcon({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        AppAssets.shake,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

```
