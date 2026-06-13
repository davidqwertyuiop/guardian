import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'create_circle_screen.dart';
import 'join_circle_screen.dart';

class AlmostInScreen extends StatelessWidget {
  const AlmostInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bgColor = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Shake icon in circle shape
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C60FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7C60FF).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Image.asset(
                  AppAssets.shake,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.circle_notifications,
                    color: Color(0xFF7C60FF),
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You're almost in",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create or Join a circle",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Option Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Create a Circle (Blue background)
                  _buildOptionCard(
                    context: context,
                    title: "Create a circle",
                    subtitle: "Start a circle & invite your people",
                    backgroundColor: const Color(0xFF007AFF),
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.of(context).push(
                        FadeRoute(page: const CreateCircleScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Join a Circle (Dark background)
                  _buildOptionCard(
                    context: context,
                    title: "Join a circle",
                    subtitle: "Enter a code from someone who invited you",
                    backgroundColor: const Color(0xFF1E1E24),
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.of(context).push(
                        FadeRoute(page: const JoinCircleScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),
            // circle-creature.png blob at the bottom
            Center(
              child: Image.asset(
                AppAssets.circleCreature,
                width: size.width * 0.75,
                height: size.height * 0.22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withValues(alpha: 0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
