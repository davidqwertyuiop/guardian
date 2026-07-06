# almost_in_screen.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/screens/almost_in_screen.dart`
* **Type:** `DART`

---

```dart

import 'package:flutter/material.dart';
import 'package:guardian/export.dart';


class AlmostInScreen extends StatelessWidget {
  const AlmostInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.read<AuthBloc>().add(const NavigateBack());
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        body: Stack(
          children: [
            // Bottom blue creature image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                AppAssets.circleCreature,
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // Main Content
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AdaptiveLayout.padding(context, 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: statusBarHeight + 20),

                    // Top shake icon circular button
                    OnboardingTopIcon(isDark: isDark),

                    SizedBox(height: AdaptiveLayout.h(context, 24)),

                    // Title
                    Text(
                      "You're almost in",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 32),
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 8)),

                    // Subtitle
                    Text(
                      "Create or Join a circle",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 15),
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 32)),

                    // Card 1: Create a Circle
                    _buildSelectionCard(
                      context: context,
                      title: "Create a circle",
                      subtitle: "Start a new circle and invite your people",
                      backgroundColor: AppColors.primary,
                      onTap: () {
                        context.read<AuthBloc>().add(const SelectCreateCircle());
                      },
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 16)),

                    // Card 2: Join a Circle
                    _buildSelectionCard(
                      context: context,
                      title: "Join a circle",
                      subtitle: "Enter a code from someone who invited you",
                      backgroundColor: isDark
                          ? const Color(0xFF1E1E22)
                          : Colors.black,
                      onTap: () {
                        context.read<AuthBloc>().add(const SelectJoinCircle());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(AdaptiveLayout.padding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AdaptiveLayout.sp(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AdaptiveLayout.h(context, 6)),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AdaptiveLayout.sp(context, 13),
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: AdaptiveLayout.h(context, 20)),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

```
