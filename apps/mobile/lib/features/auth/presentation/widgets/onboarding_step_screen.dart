import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';

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
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: AdaptiveLayout.sp(context, 32),
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.black,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: AdaptiveLayout.h(context, 16)),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: AdaptiveLayout.sp(context, 16),
                                  fontWeight: FontWeight.w400,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: AdaptiveLayout.h(context, 24)),
                              // Bullet points
                              ...bulletPoints.map((point) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: AdaptiveLayout.h(context, 12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '→ ',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: AdaptiveLayout.sp(context, 16),
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white38 : Colors.black38,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            point,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: AdaptiveLayout.sp(context, 16),
                                              fontWeight: FontWeight.w400,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
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
                                SizedBox(
                                  width: double.infinity,
                                  height: AdaptiveLayout.h(context, 54),
                                  child: ElevatedButton(
                                    onPressed: onPrimaryPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? Colors.white : Colors.black,
                                      foregroundColor: isDark ? Colors.black : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      primaryButtonText,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: AdaptiveLayout.sp(context, 16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: AdaptiveLayout.h(context, 12)),
                                SizedBox(
                                  width: double.infinity,
                                  height: AdaptiveLayout.h(context, 54),
                                  child: TextButton(
                                    onPressed: onSecondaryPressed,
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
                                      secondaryButtonText,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: AdaptiveLayout.sp(context, 16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
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
