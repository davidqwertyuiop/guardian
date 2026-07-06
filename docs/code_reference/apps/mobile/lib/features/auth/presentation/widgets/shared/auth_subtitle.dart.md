# auth_subtitle.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/widgets/shared/auth_subtitle.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class AuthSubtitle extends StatelessWidget {
  final String text;

  const AuthSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: AdaptiveLayout.sp(context, 16),
        fontWeight: FontWeight.w400,
        color: isDark ? Colors.white70 : Colors.black87,
        height: 1.4,
      ),
    );
  }
}

```
