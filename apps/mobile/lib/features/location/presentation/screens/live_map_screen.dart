import 'package:flutter/material.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:guardian/features/journey/presentation/screens/start_journey_screen.dart';
import 'package:guardian/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:guardian/features/location/presentation/screens/location_history_screen.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = locator<AuthBloc>();
      if (authBloc.state.isJoiningCircle) {
        _showYoureInSheet();
      }
    });
  }

  void _showYoureInSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16161A) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: 24 + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // icon1.png at top of sheet
              Image.asset(
                AppAssets.icon1,
                width: 60,
                height: 60,
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                "You're in 🤝",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "You've joined Ngozi's circle. You can now see each other's location.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Button: Go to map
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    locator<AuthBloc>().add(const CompleteCircleOnboarding());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Go to map",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Simulated Map Background
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF111116) : const Color(0xFFF0EFFF),
              child: CustomPaint(painter: MapGridPainter(isDark: isDark)),
            ),
          ),
          // Top Status Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E28).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Circle: Ngozi\'s Circle',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.people_outline, color: AppColors.primary),
                ],
              ),
            ),
          ),
          // Floating SOS and Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'journey',
                      onPressed: () => Navigator.of(
                        context,
                      ).push(FadeRoute(page: const StartJourneyScreen())),
                      icon: const Icon(Icons.directions_run),
                      label: const Text(
                        'Journey',
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    FloatingActionButton(
                      heroTag: 'sos',
                      onPressed: () => Navigator.of(
                        context,
                      ).push(FadeRoute(page: const EmergencyScreen())),
                      backgroundColor: Colors.redAccent,
                      child: const Icon(
                        Icons.sos,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: 'history',
                      onPressed: () => Navigator.of(
                        context,
                      ).push(FadeRoute(page: const LocationHistoryScreen())),
                      backgroundColor: isDark
                          ? const Color(0xFF1C1C28)
                          : Colors.white,
                      child: const Icon(
                        Icons.history,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final bool isDark;
  MapGridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
