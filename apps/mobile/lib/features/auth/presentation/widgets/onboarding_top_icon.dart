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
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.05),
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
