import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/onboarding_cubit.dart';
import 'youre_in_screen.dart';

class CircleEmptyScreen extends StatefulWidget {
  const CircleEmptyScreen({super.key});

  @override
  State<CircleEmptyScreen> createState() => _CircleEmptyScreenState();
}

class _CircleEmptyScreenState extends State<CircleEmptyScreen> {
  String _inviteLink = '';

  @override
  void initState() {
    super.initState();
    _loadInviteLink();
  }

  Future<void> _loadInviteLink() async {
    final code = context.read<OnboardingCubit>().state.circleCode;
    final prefs = await SharedPreferences.getInstance();
    final link = prefs.getString('invite_link');
    if (link != null && link.isNotEmpty) {
      setState(() {
        _inviteLink = link;
      });
    } else {
      setState(() {
        _inviteLink = "wa.me/guardian/${code.isNotEmpty ? code.toLowerCase() : 'abc123'}";
      });
    }
  }

  void _onDone() {
    Navigator.of(context).push(
      FadeRoute(page: const YoureInScreen(circleCreatorName: "You")),
    );
  }

  void _shareOnWhatsApp() async {
    final message = Uri.encodeComponent("Hey! Join my Guardian safety circle using this link: https://$_inviteLink");
    final url = Uri.parse("whatsapp://send?text=$message");
    final webUrl = Uri.parse("https://wa.me/?text=$message");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      Clipboard.setData(ClipboardData(text: _inviteLink));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp not installed. Link copied to clipboard!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : Colors.black;

    final displayLink = _inviteLink.isNotEmpty
        ? _inviteLink
        : "wa.me/guardian/abc123";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background map graphic covering the screen
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.08 : 0.12,
                child: Image.asset(
                  AppAssets.mapAddress,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top illustration - Blue disk with rings
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: BlueDiskPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "Your circle is ready 🎉",
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "Invite your people so they can see you're safe.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Link Container with Copy Icon
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayLink,
                            style: GoogleFonts.inter(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: displayLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Link copied to clipboard"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 20,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  Column(
                    children: [
                      // Share on WhatsApp button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _shareOnWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardColor,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share, color: Colors.green, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "Share on WhatsApp",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Done - I'll invite them later button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _onDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardColor,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Done — I'll invite them later",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlueDiskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Blue disk base
    final diskPaint = Paint()
      ..color = const Color(0xFF007AFF)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 70, height: 45),
      diskPaint,
    );

    // Inside rings/circle shapes representing the design
    final ringPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(center.dx - 12, center.dy - 4), 5, ringPaint);
    canvas.drawCircle(Offset(center.dx + 12, center.dy - 6), 5, ringPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 8), 5, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
