# fade_page_transitions_builder.dart

* **File Path:** `apps/mobile/lib/core/theme/fade_page_transitions_builder.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';

class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Entry easing curve (ease-out-expo style curve for premium fluid deceleration)
    final entryCurve = CurvedAnimation(
      parent: animation,
      curve: const Cubic(0.16, 1, 0.3, 1),
      reverseCurve: const Cubic(0.16, 1, 0.3, 1).flipped,
    );

    // Exit easing curve for when this route is covered by another route
    final exitCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Cubic(0.16, 1, 0.3, 1),
      reverseCurve: const Cubic(0.16, 1, 0.3, 1).flipped,
    );

    // Incoming page slides from full right off-screen to center
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(entryCurve);

    // Outgoing page slides slightly to the left (parallax effect)
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.24, 0.0),
    ).animate(exitCurve);

    // Combine entry slide and exit slide
    return SlideTransition(
      position: slideOut,
      child: SlideTransition(position: slideIn, child: child),
    );
  }
}

```
