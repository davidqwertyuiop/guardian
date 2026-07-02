import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class AuthBackgroundEllipses extends StatelessWidget {
  final bool isKeyboardOpen;

  const AuthBackgroundEllipses({super.key, this.isKeyboardOpen = false});

  @override
  Widget build(BuildContext context) {
    if (isKeyboardOpen) return const SizedBox.shrink();

    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 20),
          left: AdaptiveLayout.w(context, 20),
          child: Image.asset(
            AppAssets.ellipse1,
            width: 40,
            opacity: const AlwaysStoppedAnimation(0.6),
          ),
        ),
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 100),
          right: AdaptiveLayout.w(context, 30),
          child: Image.asset(
            AppAssets.ellipse2,
            width: 30,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
        ),
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 250),
          left: AdaptiveLayout.w(context, 10),
          child: Image.asset(
            AppAssets.ellipse3,
            width: 50,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
        ),
        Positioned(
          top: statusBarHeight + AdaptiveLayout.h(context, 350),
          right: AdaptiveLayout.w(context, 15),
          child: Image.asset(
            AppAssets.ellipse4,
            width: 35,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
        ),
      ],
    );
  }
}
