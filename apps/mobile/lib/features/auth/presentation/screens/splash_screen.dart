import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';
import 'package:guardian/features/location/presentation/screens/live_map_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = locator<SharedPreferences>();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    final token = await TokenManager().getAccessToken();
    final hasJwt = token != null && token.isNotEmpty;

    if (mounted) {
      Widget nextPage;
      if (onboardingCompleted && hasJwt) {
        nextPage = const LiveMapScreen();
      } else {
        nextPage = const WelcomeScreen();
      }
      Navigator.of(context).pushReplacement(FadeRoute(page: nextPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.logo,
              width: AdaptiveLayout.w(context, 100),
              height: AdaptiveLayout.h(context, 100),
              fit: BoxFit.contain,
            ),
            SizedBox(height: AdaptiveLayout.h(context, 16)),
            Text(
              'guardian',
              style: GoogleFonts.outfit(
                fontSize: AdaptiveLayout.sp(context, 32),
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
