import 'package:flutter/material.dart';
import 'package:guardian/core/utils/responsive_scale.dart';

class TopBarSosPill extends StatelessWidget {
  final double height;
  final double paddingHorizontal;
  final double paddingVertical;
  final double gap;
  final bool isDark;
  final VoidCallback onTap;

  const TopBarSosPill({
    super.key,
    required this.height,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.gap,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF2F2F5),
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SOS',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: context.sp(14),
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF3380),
              ),
            ),
            SizedBox(width: gap),
            Container(
              width: context.w(28),
              height: context.w(28),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3380),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: context.w(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
