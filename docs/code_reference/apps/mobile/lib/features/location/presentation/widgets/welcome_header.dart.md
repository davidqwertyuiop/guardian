# welcome_header.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/widgets/welcome_header.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/core/utils/responsive_scale.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String weatherGreeting;
  const WelcomeHeader({
    super.key,
    required this.userName,
    required this.weatherGreeting,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome $userName,',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: context.sp(26),
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weatherGreeting,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF888899),
            ),
          ),
        ],
      ),
    );
  }
}

```
