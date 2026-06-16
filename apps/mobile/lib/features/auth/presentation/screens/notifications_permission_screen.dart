import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardian/features/auth/presentation/widgets/onboarding_step_screen.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class NotificationsPermissionScreen extends StatelessWidget {
  const NotificationsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OnboardingStepScreen(
      title: 'Stay in the loop',
      subtitle: 'We\'ll notify you when:',
      bulletPoints: const [
        'Someone in your circle activates SOS',
        'A circle member starts broadcasting',
        'Someone new joins your circle',
      ],
      primaryButtonText: 'Turn on notifications',
      secondaryButtonText: 'Skip — I\'ll miss these alerts',
      onPrimaryPressed: () {
        locator<AuthBloc>().add(const EnableNotifications());
      },
      onSecondaryPressed: () {
        locator<AuthBloc>().add(const SkipNotifications());
      },
      headerIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            AppAssets.phBell,
            width: 24,
            height: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      middleWidget: Container(
        margin: EdgeInsets.only(top: AdaptiveLayout.h(context, 24)),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AdaptiveLayout.padding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Chroma-like premium app icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF2D55),
                          Color(0xFFFF9500),
                          Color(0xFF5856D6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SizedBox(width: AdaptiveLayout.w(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chroma™',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: AdaptiveLayout.sp(context, 14),
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '42 min ago',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AdaptiveLayout.sp(context, 12),
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AdaptiveLayout.h(context, 10)),
              Text(
                'You have two new dreams from last night. Want to unroll them?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(context, 14),
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
