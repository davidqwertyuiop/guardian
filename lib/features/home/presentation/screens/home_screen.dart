import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F8FA);
    final cardColor = isDark ? const Color(0xFF16161D) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E24);
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF7C60FF), Color(0xFFAC9BFF)],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: subtextColor,
                            ),
                          ),
                          Text(
                            "Guardian User",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: textColor,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mock Map Container
              Text(
                "Live Location Tracking",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: size.height * 0.32,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Mock Map Graphic using shapes/icons
                    Positioned.fill(
                      child: Container(
                        color: isDark ? const Color(0xFF111116) : const Color(0xFFECEBF2),
                        child: CustomPaint(
                          painter: MapMockPainter(isDark: isDark),
                        ),
                      ),
                    ),

                    // Floating Card overlay on Map
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34C759).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.share_location_sharp,
                                    color: Color(0xFF34C759),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Broadcasting",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      "Sharing location with your active circle",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: true,
                              activeThumbColor: const Color(0xFF7C60FF),
                              onChanged: (val) {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Circle Members List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Circle Status",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Manage",
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Mock members row
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCircleMember(
                      name: "Sarah (Mom)",
                      status: "At Home",
                      time: "Just now",
                      avatarColor: Colors.pinkAccent,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardColor: cardColor,
                      isDark: isDark,
                    ),
                    _buildCircleMember(
                      name: "Alex (Brother)",
                      status: "At Work",
                      time: "10m ago",
                      avatarColor: Colors.blueAccent,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardColor: cardColor,
                      isDark: isDark,
                    ),
                    _buildCircleMember(
                      name: "David (Friend)",
                      status: "Offline",
                      time: "2h ago",
                      avatarColor: Colors.amber,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardColor: cardColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SOS Quick Action Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF7B7B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emergency SOS",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Press to instantly alert your family members and share your coordinates.",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
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
        ),
      ),
    );
  }

  Widget _buildCircleMember({
    required String name,
    required String status,
    required String time,
    required Color avatarColor,
    required Color textColor,
    required Color subtextColor,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: avatarColor,
                child: Text(
                  name[0],
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status == "Offline" ? Colors.grey : const Color(0xFF34C759),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MapMockPainter extends CustomPainter {
  final bool isDark;

  MapMockPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    // Grid lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Mock roads/routes
    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.5, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.1, size.height), Offset(size.width * 0.8, 0), roadPaint);

    // Current User Dot (Purple Glow)
    final glowPaint = Paint()
      ..color = const Color(0xFF7C60FF).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = const Color(0xFF7C60FF)
      ..style = PaintingStyle.fill;

    final userLoc = Offset(size.width * 0.5, size.height * 0.45);
    canvas.drawCircle(userLoc, 18, glowPaint);
    canvas.drawCircle(userLoc, 6, dotPaint);

    // Other members pins
    final pinPaint = Paint()
      ..color = const Color(0xFF34C759)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.32), 5, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 5, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
