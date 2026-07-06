
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:guardian/export.dart';


class CircleEmptyScreen extends StatelessWidget {
  const CircleEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final inviteLink = context.read<AuthBloc>().state.inviteLink ?? "";

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
            // map-address.png background
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.15 : 0.6,
                child: Image.asset(AppAssets.mapAddress, fit: BoxFit.cover),
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
                    OnboardingTopIcon(isDark: isDark),

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

                    // ── Link row ────────────────────────────────────────────
                    // Left: link text box (flexible, takes remaining space)
                    // Right: copy button (fixed 87px wide, 43px tall per spec)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Long link box
                        Expanded(
                          child: Container(
                            height: AdaptiveLayout.h(context, 43),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              inviteLink,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                // Spec: 12px, letter-spacing -2%
                                fontSize: AdaptiveLayout.sp(context, 12),
                                letterSpacing: -0.24, // 12 * -0.02
                                height: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Copy button — spec: 87w × 43h, radius 12, pad 13v/14h
                        SizedBox(
                          width: _adaptiveCopyWidth(screenWidth),
                          height: AdaptiveLayout.h(context, 43),
                          child: ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: inviteLink),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Link copied!",
                                    style: TextStyle(fontFamily: 'Inter'),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white
                                  : Colors.black,
                              foregroundColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Copy link",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: AdaptiveLayout.sp(context, 12),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.24,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Share invite link button (universal system share sheet)
                    SizedBox(
                      width: double.infinity,
                      height: AdaptiveLayout.h(context, 54),
                      child: ElevatedButton(
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: 'Join my Guardian circle: $inviteLink',
                              subject: 'Guardian circle invite',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.ios_share_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Share invite link",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: AdaptiveLayout.sp(context, 16),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AdaptiveLayout.h(context, 24) + bottomPad),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Scale the copy button width proportionally so it always looks right
  /// regardless of screen size. Reference is 87px on a 390px-wide screen.
  double _adaptiveCopyWidth(double screenWidth) {
    const referenceWidth = 390.0;
    const referenceButtonWidth = 87.0;
    final ratio = screenWidth / referenceWidth;
    return (referenceButtonWidth * ratio).clamp(70.0, 110.0);
  }
}
