import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class OpenMapButton extends StatelessWidget {
  final VoidCallback onTap;

  const OpenMapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(140),
        height: context.w(40),
        decoration: BoxDecoration(
          color: const Color(0xFF8E9BFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.openMapIcon,
              width: context.w(16),
              height: context.w(16),
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'Open map',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: context.sp(13),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
