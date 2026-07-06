# auth_secondary_button.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/widgets/shared/auth_secondary_button.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class AuthSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AuthSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: AdaptiveLayout.h(context, 54),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF1E1E22)
              : const Color(0xFFF3F3F6),
          foregroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AdaptiveLayout.sp(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

```
