import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../widgets/onboarding_widgets.dart';
import 'almost_in_screen.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  Future<void> _initializeFirebaseMessaging() async {
    // MOCK FIREBASE PUSH NOTIFICATION INITIALIZATION SECTION
    // Once Firebase is activated, uncomment the following block:
    /*
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        debugPrint("Firebase Messaging token: $token");
      }
    } catch (e) {
      debugPrint("Error initializing Firebase: $e");
    }
    */
    debugPrint("Firebase push notifications mock initialized successfully.");
  }

  void _onTurnOnNotifications(BuildContext context) async {
    await _initializeFirebaseMessaging();
    if (context.mounted) {
      Navigator.of(context).push(
        FadeRoute(page: const AlmostInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Bell icon surrounded by circular container
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C60FF).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7C60FF).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Image.asset(
                          AppAssets.phBell,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.notifications_active,
                            color: Color(0xFF7C60FF),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Stay in the loop",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "We'll notify you when:",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBulletPoint("Someone in your circle activates SOS", isDark),
                  _buildBulletPoint("A circle member starts broadcasting", isDark),
                  _buildBulletPoint("Someone new joins your circle", isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Background image map-intro.png covering the center bottom area adaptively
            Expanded(
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  AppAssets.mapIntro,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  PrimaryButton(
                    text: "Turn on notifications",
                    onPressed: () => _onTurnOnNotifications(context),
                  ),
                  const SizedBox(height: 8),
                  SecondaryTextButton(
                    text: "Not now (it's fine)",
                    onPressed: () => _onTurnOnNotifications(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Color(0xFF7C60FF), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
