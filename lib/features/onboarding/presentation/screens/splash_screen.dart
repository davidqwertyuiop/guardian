import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guardian/core/utils/fade_route.dart';

import 'onboarding_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Controller for the entrance fade and scale
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Controller for the continuous "loading" pulse effect on the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Breathes/pulses the logo to simulate loading state
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Route dynamically based on onboarding status saved in SharedPreferences
    Future.delayed(const Duration(milliseconds: 5000), () async {
      if (!mounted) return;

      Widget targetScreen = const OnboardingScreen();
      try {
        final prefs = await SharedPreferences.getInstance();
        final showSignIn = prefs.getBool('show_sign_in') ?? false;
        if (showSignIn) {
          targetScreen = const SignInScreen();
        }
      } catch (e) {
        debugPrint("SharedPreferences error: $e");
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(FadeRoute(page: targetScreen));
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final bgColor = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final logoSize = size.width * 0.28;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Full-screen background fill
          Positioned.fill(child: Container(color: bgColor)),

          // Radial glow behind the logo
          Positioned(
            top: size.height * 0.35,
            left: size.width / 2 - logoSize * 1.2,
            child: Container(
              width: logoSize * 2.4,
              height: logoSize * 2.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(
                      0xFF7C60FF,
                    ).withValues(alpha: isDark ? 0.18 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Centered content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulse animation on the Logo Container to look "as if its loading"
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C28)
                              : const Color(0xFFF4F1FF),
                          borderRadius: BorderRadius.circular(logoSize * 0.25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF7C60FF,
                              ).withValues(alpha: isDark ? 0.35 : 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(logoSize * 0.12),
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.shield_outlined,
                              size: logoSize * 0.55,
                              color: const Color(0xFF7C60FF),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.025),

                    // Brand name
                    Text(
                      'Guardian',
                      style: GoogleFonts.outfit(
                        fontSize: size.width * 0.09,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: size.height * 0.008),

                    Text(
                      'Know they\'re safe.',
                      style: GoogleFonts.inter(
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.w400,
                        color: textColor.withValues(alpha: 0.5),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
