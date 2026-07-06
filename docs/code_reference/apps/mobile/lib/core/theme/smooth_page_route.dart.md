# smooth_page_route.dart

* **File Path:** `apps/mobile/lib/core/theme/smooth_page_route.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothPageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Cubic easing curve for premium, organic feeling deceleration
          final entryCurve = CurvedAnimation(
            parent: animation,
            curve: const Cubic(
              0.16,
              1,
              0.3,
              1,
            ), // custom cubic-bezier (ease-out-expo style)
            reverseCurve: const Cubic(0.16, 1, 0.3, 1).flipped,
          );

          final exitCurve = CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Cubic(0.16, 1, 0.3, 1),
          );

          // New page sliding in from the right
          final slideIn = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(entryCurve);

          // Previous page sliding slightly left (parallax effect)
          final slideOut = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.24, 0.0),
          ).animate(exitCurve);

          return SlideTransition(
            position: slideOut,
            child: SlideTransition(position: slideIn, child: child),
          );
        },
      );
}

```
