import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.sizeOf(context).height;
    final isCompact = screenH < 720 || AdaptiveLayout.isLandscape(context);
    final cardHeight = isCompact ? 520.0 : screenH * 0.58;
    final cardPadding = isCompact ? 24.0 : AdaptiveLayout.padding(context, 24);
    final headlineSize = isCompact
        ? 44.0
        : AdaptiveLayout.sp(context, 52).clamp(44.0, 58.0);
    final bodySize = isCompact
        ? 15.0
        : AdaptiveLayout.sp(context, 18).clamp(15.0, 20.0);
    final imageWidth = isCompact
        ? 240.0
        : AdaptiveLayout.w(context, 300).clamp(240.0, 340.0);

    return Container(
      width: double.infinity,
      height: cardHeight,
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
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: cardHeight * 0.03),
                  Text(
                    "Know\nthey're\nsafe.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: headlineSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.045),
                  Text(
                    "The simplest way to share your location with the people who matter most.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: bodySize,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.038),
                  Center(
                    child: Image.asset(
                      AppAssets.line2,
                      width: imageWidth,
                      height: cardHeight * (isCompact ? 0.12 : 0.16),
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
