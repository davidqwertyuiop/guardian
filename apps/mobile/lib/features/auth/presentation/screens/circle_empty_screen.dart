import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class CircleEmptyScreen extends StatelessWidget {
  const CircleEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        locator<AuthBloc>().add(const NavigateBack());
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        body: Stack(
          children: [
            // Map address background image
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.15 : 0.6,
                child: Image.asset(
                  AppAssets.mapAddress,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
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

                    // Top shake icon
                    _buildTopIcon(context, isDark),

                    SizedBox(height: AdaptiveLayout.h(context, 24)),

                    // Title
                    Text(
                      "Your circle is empty",
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
                      "Share the link below so your people can join and see you're safe.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 15),
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 32)),

                    // Link sharing row
                    Row(
                      children: [
                        // Link box (blue)
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "wa.me/guardian/abc123",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Copy link button (black)
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Clipboard.setData(
                                  const ClipboardData(text: "wa.me/guardian/abc123"),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Link copied!"),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Copy link",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // WhatsApp share button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Share on WhatsApp",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 16)),

                    // Share another way link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Complete onboarding
                          locator<AuthBloc>().add(const CompleteCircleOnboarding());
                        },
                        child: Text(
                          "Share another way",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: AdaptiveLayout.sp(context, 14),
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIcon(BuildContext context, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
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
