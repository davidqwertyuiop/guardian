import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import '../widgets/onboarding_widgets.dart';
import 'notification_permission_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    Navigator.of(context).push(
      FadeRoute(page: const NotificationPermissionScreen()),
    );
  }

  void _showPlatformDialog() {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Theme(
          data: ThemeData.light(),
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              width: 270,
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Allow \"Guardian\" to use your location?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Guardian requires location access to keep your circle members updated on your safety.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Colors.black12),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToNext();
                    },
                    child: Text(
                      "Allow While Using App",
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: const Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToNext();
                    },
                    child: Text(
                      "Allow Once",
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToNext();
                    },
                    child: Text(
                      "Don't Allow",
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF007AFF), size: 32),
                const SizedBox(height: 16),
                Text(
                  "Allow Guardian to access this device's location?",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.blur_on, size: 36, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text("Approximate", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            border: Border.all(color: const Color(0xFF007AFF)),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.gps_fixed, size: 36, color: Color(0xFF007AFF)),
                        ),
                        const SizedBox(height: 8),
                        Text("Precise", style: GoogleFonts.inter(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToNext();
                  },
                  child: Text(
                    "While using the app",
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToNext();
                  },
                  child: Text(
                    "Only this time",
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToNext();
                  },
                  child: Text(
                    "Don't allow",
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        automaticallyImplyLeading: false, // Remove leading back button
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
                  const OnboardingTitleHeader(
                    title: "Guardian needs your location",
                    subtitle: "So your circle knows you're safe — even when the app is closed.",
                  ),
                  const SizedBox(height: 20),
                  _buildBulletPoint("Your circle sees where you are", isDark),
                  _buildBulletPoint("You always control who sees it", isDark),
                  _buildBulletPoint("You can pause or stop anytime", isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Covers entire bottom area adaptively
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        AppAssets.mapIntro,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.map, size: 80, color: Colors.grey),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: MapPulsePainter(progress: _pulseController.value),
                          child: const SizedBox(width: 120, height: 120),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  PrimaryButton(
                    text: "Turn on location",
                    onPressed: _showPlatformDialog,
                  ),
                  const SizedBox(height: 8),
                  SecondaryTextButton(
                    text: "Not now - I'll do this later",
                    onPressed: _navigateToNext,
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
          const Icon(Icons.check_circle_outline, color: Color(0xFF7C60FF), size: 18),
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

class MapPulsePainter extends CustomPainter {
  final double progress;

  MapPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF7C60FF).withValues(alpha: (1.0 - progress) * 0.45)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, progress * 40, paint);

    final dotPaint = Paint()
      ..color = const Color(0xFF7C60FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
