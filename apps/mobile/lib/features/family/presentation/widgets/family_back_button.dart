import 'dart:ui';
import 'package:flutter/material.dart';

class FamilyBackButton extends StatelessWidget {
  const FamilyBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.2, sigmaY: 3.2),
        child: Material(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF4F4F5),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: EdgeInsets.all(6.4),
                child: Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
