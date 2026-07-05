import 'dart:io';
import 'package:flutter/material.dart';

class YouAreLiveBottomSheet extends StatelessWidget {
  final String destination;

  const YouAreLiveBottomSheet({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgBoxColor = isDark ? const Color(0xFF1E1E24) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 24,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgBoxColor,
          borderRadius: BorderRadius.circular(32),
        ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Icon
              Image.asset(
                'assets/icons/youareliveicon.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                "You're live",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Your circle has been notified. They can see you heading ${destination.toLowerCase()}. Tap the banner at the top to stop early.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: Platform.isIOS ? 42 : 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF0F5),
                          foregroundColor: const Color(0xFFFF4081),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Platform.isIOS ? 100 : 16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Leave circle",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // gap: 10px
                  Expanded(
                    child: SizedBox(
                      height: Platform.isIOS ? 42 : 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Platform.isIOS ? 100 : 16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Stay",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ));
  }
}
