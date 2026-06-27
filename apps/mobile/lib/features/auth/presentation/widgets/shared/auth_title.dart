import 'package:flutter/material.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class AuthTitle extends StatelessWidget {
  final String text;

  const AuthTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: AdaptiveLayout.sp(context, 32),
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : Colors.black,
        height: 1.15,
        letterSpacing: -0.5,
      ),
    );
  }
}
