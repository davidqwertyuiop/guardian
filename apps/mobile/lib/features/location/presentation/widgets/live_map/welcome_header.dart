import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String weatherGreeting;
  final bool isLoading;
  const WelcomeHeader({
    super.key,
    required this.userName,
    required this.weatherGreeting,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${userName.isNotEmpty && userName != 'User' ? userName : (isLoading ? '...' : 'User')},',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: context.sp(26),
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weatherGreeting,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF888899),
            ),
          ),
        ],
      ),
    );
  }
}
