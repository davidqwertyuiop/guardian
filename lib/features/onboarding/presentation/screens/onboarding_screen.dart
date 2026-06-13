import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'join_circle_screen.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../widgets/floating_tag.dart';
import '../widgets/wave_line_painter.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive card height — leaves room for buttons at bottom
    final cardHeight = size.height * 0.68;

    // Status bar style
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final bgColor = isDark ? const Color(0xFF0A0A0F) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background fills under status bar
          Positioned.fill(child: Container(color: bgColor)),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ─── Purple Hero Card ────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.012,
                  ),
                  child: Container(
                    height: cardHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        children: [
                          // Subtle map/grid background overlay
                          Positioned(
                            right: -30,
                            bottom: -30,
                            width: size.width * 0.85,
                            height: cardHeight * 0.55,
                            child: Opacity(
                              opacity: 0.12,
                              child: Image.asset(
                                AppAssets.mapIntro,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, st) =>
                                    const SizedBox(),
                              ),
                            ),
                          ),

                          // Card content
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              size.width * 0.06,
                              size.height * 0.022,
                              size.width * 0.06,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.06),

                                // ── Title ────────────────────────────
                                Text(
                                  "Know\nthey're\nsafe.",
                                  style: GoogleFonts.outfit(
                                    fontSize: size.width * 0.115,
                                    fontWeight: FontWeight.w800,
                                    height: 1.08,
                                    color: Colors.white,
                                  ),
                                ),

                                SizedBox(height: size.height * 0.018),

                                // ── Subtitle ─────────────────────────
                                SizedBox(
                                  width: size.width * 0.6,
                                  child: Text(
                                    "The simplest way to share your location with the people who matter most.",
                                    style: GoogleFonts.inter(
                                      fontSize: size.width * 0.038,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white
                                          .withValues(alpha: 0.82),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Wave decoration
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: cardHeight * 0.20,
                            height: 56,
                            child: const CustomPaint(
                              painter: WaveLinePainter(),
                            ),
                          ),

                          // Floating scattered keyword tags
                          Positioned(
                            left: size.width * 0.04,
                            bottom: size.height * 0.022,
                            right: size.width * 0.04,
                            height: 86,
                            child: Stack(
                              children: [
                                FloatingTag(
                                  text: "safety",
                                  left: 0,
                                  bottom: 10,
                                  rotation: -0.15,
                                  fontSize: size.width * 0.033,
                                ),
                                FloatingTag(
                                  text: "location",
                                  left: size.width * 0.19,
                                  bottom: 28,
                                  rotation: 0.18,
                                  fontSize: size.width * 0.033,
                                ),
                                FloatingTag(
                                  text: "circle",
                                  left: size.width * 0.38,
                                  bottom: 44,
                                  rotation: -0.08,
                                  fontSize: size.width * 0.033,
                                ),
                                FloatingTag(
                                  text: "broadcast",
                                  left: size.width * 0.49,
                                  bottom: 14,
                                  rotation: 0.12,
                                  fontSize: size.width * 0.033,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // ─── Action Buttons ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.06,
                    0,
                    size.width * 0.06,
                    size.height * 0.04,
                  ),
                  child: Column(
                    children: [
                      // Create Account
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.068,
                        child: ElevatedButton(
                          onPressed: () {
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setBool('show_sign_in', true);
                            }).catchError((e) {
                              debugPrint("SharedPreferences error: $e");
                            });

                            Navigator.of(context).push(
                              FadeRoute(page: const SignInScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Create an account",
                            style: GoogleFonts.inter(
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.014),

                      // Invite Link
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.068,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              FadeRoute(page: const JoinCircleScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E28)
                                : const Color(0xFFF3F3F6),
                            foregroundColor:
                                isDark ? Colors.white : Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "I have an invite link",
                            style: GoogleFonts.inter(
                              fontSize: size.width * 0.042,
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
        ],
      ),
    );
  }
}
