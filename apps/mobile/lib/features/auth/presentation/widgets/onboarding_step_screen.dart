import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardian/features/auth/presentation/widgets/shared/auth_shared.dart';

class OnboardingStepScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> bulletPoints;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final Widget? headerIcon;
  final Widget? middleWidget;

  const OnboardingStepScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bulletPoints,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.headerIcon,
    this.middleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        locator<AuthBloc>().add(const NavigateBack());
      },
      child: Scaffold(
        body: Stack(
        children: [
          // Bottom Design watermark silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AppAssets.bottomDesign,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SafeArea(
            top: false, // Extend layout under status bar
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AdaptiveLayout.padding(context, 24),
                        right: AdaptiveLayout.padding(context, 24),
                        bottom: AdaptiveLayout.padding(context, 20),
                        top: MediaQuery.paddingOf(context).top + AdaptiveLayout.padding(context, 10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (headerIcon != null) ...[
                                headerIcon!,
                                SizedBox(height: AdaptiveLayout.h(context, 20)),
                              ] else ...[
                                SizedBox(height: AdaptiveLayout.h(context, 10)),
                              ],
                              AuthTitle(text: title),
                              SizedBox(height: AdaptiveLayout.h(context, 16)),
                              AuthSubtitle(text: subtitle),
                              SizedBox(height: AdaptiveLayout.h(context, 24)),
                              AuthBulletList(bulletPoints: bulletPoints),
                              if (middleWidget != null) ...[
                                SizedBox(height: AdaptiveLayout.h(context, 20)),
                                middleWidget!,
                              ],
                            ],
                          ),
                          // Buttons section
                          Padding(
                            padding: EdgeInsets.only(
                              top: AdaptiveLayout.h(context, 30),
                            ),
                            child: Column(
                              children: [
                                AuthPrimaryButton(
                                  text: primaryButtonText,
                                  onPressed: onPrimaryPressed,
                                ),
                                SizedBox(height: AdaptiveLayout.h(context, 12)),
                                AuthSecondaryButton(
                                  text: secondaryButtonText,
                                  onPressed: onSecondaryPressed,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
