import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: AdaptiveLayout.h(context, 510),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary : const Color(0xFF8069FF),
        borderRadius: BorderRadius.circular(40),
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF8069FF), Color(0xFF6C38FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          children: [
            // Watermark background image
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(AppAssets.line6, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AdaptiveLayout.padding(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AdaptiveLayout.h(context, 16)),
                  Text(
                    "Know\nthey're\nsafe.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AdaptiveLayout.sp(context, 52),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: AdaptiveLayout.h(context, 24)),
                  Text(
                    "The simplest way to share your location with the people who matter most.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AdaptiveLayout.sp(context, 20),
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 28 / 18,
                    ),
                  ),
                  SizedBox(height: AdaptiveLayout.h(context, 20)),
                  Center(
                    child: Image.asset(
                      AppAssets.line2,
                      width: AdaptiveLayout.w(context, 300),
                      height: AdaptiveLayout.h(context, 80),
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            _capsule("safety", bottom: 25, left: 25, rot: -0.05),
            _capsule("location", bottom: 40, left: 65, rot: 0.65),
            _capsule("circle", bottom: 70, left: 100, rot: -0.25),
            _capsule("broadcast", bottom: 30, left: 135, rot: 0.40),
          ],
        ),
      ),
    );
  }

  Widget _capsule(
    String text, {
    required double bottom,
    double? left,
    double? right,
    required double rot,
  }) {
    return Positioned(
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rot,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
